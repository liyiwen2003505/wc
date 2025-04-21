class BooksController < ApplicationController

  before_action :set_user

  before_action :validate_book_id, only: [:show]

  def validate_book_id
    unless params[:id] =~ /^\d+$/ # 正则表达式检查 ID 是否是纯数字
      redirect_to books_path, alert: "书籍 ID 不合法！"
    end
  end

  def index
      # 创建 Ransack 查询对象
      begin
      @q = Book.ransack(params[:q])  # 对 book 模型进行查询，并赋值给 @q
      @logger.info("创建查询对象，搜索条件: #{params[:q].inspect}")

      # 获取查询结果，分页，不包含重复数据
      @books = @q.result(distinct: true).page(params[:page]).per(3)

      # 获取总页数
      total_pages = @books.total_pages
      @logger.info("总页数: #{total_pages}")

      # 如果用户输入的页码超出范围，跳转到第一页并提示
      if params[:page].to_i > total_pages
        @logger.warn("访问的页码超出范围，用户请求页码: #{params[:page]}, 总页数: #{total_pages}")
        redirect_to books_path, alert: "您访问的页码不存在！"
      else
        @logger.info("成功查询到书籍，当前页: #{params[:page] || 1}")
      end
      rescue => e
        @logger.error("发生错误，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
      end

  end


  def set_user
    @user = current_user # 或者你自己的方法获取用户
  end

  def show
    @book = Book.find_by(id: params[:id])
    if @book.nil?
      redirect_to books_path, alert: "该书籍不存在！"
    end  # 显示单本书的详细信息  根据Url中的id参数获取书籍的详细信息
  end

  def edit
    @book = Book.find_by(id: params[:id])
    if @book.nil?
      redirect_to books_path, alert: "该书籍不存在，无法编辑！"
    end
  end

  def new
    @book = Book.new
  end

  def update
    @book = Book.find(params[:id])

    begin
      @logger.info("开始更新书籍，书籍ID: #{@book.id}")

      # 检查书名不能为空
      unless book_params[:title].present?
        flash[:alert] = "书名不能为空！"
        @logger.warn("书名为空，无法更新书籍，书籍ID: #{@book.id}")
        redirect_to edit_book_path and return
      end

      # 校验参数
      errors = []
      errors << "数量必须是大于0且不超过1000的整数" unless valid_total?(book_params[:total])

      if errors.any?
        flash.now[:alert] = errors.join("；")
        @logger.warn("参数校验失败，错误信息: #{errors.join('；')}, 书籍ID: #{@book.id}")
        render :edit and return
      end

      # 查找作者和分类
      author = Author.find_by(id: book_params[:author_id])
      category = Category.find_by(id: book_params[:category_id])

      if author.nil?
        flash.now[:alert] = "请选择有效的作者！"
        @logger.warn("无效的作者ID: #{book_params[:author_id]}, 书籍ID: #{@book.id}")
        render :edit and return
      end

      if category.nil?
        flash.now[:alert] = "请选择有效的分类！"
        @logger.warn("无效的分类ID: #{book_params[:category_id]}, 书籍ID: #{@book.id}")
        render :edit and return
      end

      # 查询是否存在具有相同书名和作者的书籍
      existing_book = Book.find_by(title: book_params[:title], author_id: author.id)

      if existing_book && existing_book.id != @book.id
        flash.now[:alert] = '该书籍名称和作者已存在，请更换书名或作者！'
        @logger.warn("书名和作者已存在，书籍ID: #{@book.id}, 重复书籍ID: #{existing_book.id}")
        render :edit and return
      end

      # 更新书籍信息
      if @book.update(
        title: book_params[:title],
        description: book_params[:description],
        total: book_params[:total],
        author_id: author.id,
        category_id: category.id
      )
        @logger.info("书籍更新成功，书籍ID: #{@book.id}")
        redirect_to books_path, notice: '书籍更新成功！'
      else
        flash.now[:alert] = @book.errors.full_messages.to_sentence
        @logger.warn("书籍更新失败，错误信息: #{@book.errors.full_messages.to_sentence}, 书籍ID: #{@book.id}")
        render :edit
      end
    rescue => e
      @logger.error("更新书籍时发生错误，书籍ID: #{@book.id}, 错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end




  def create
    begin
      @logger.info("开始创建新书籍，提交的参数: #{book_params.inspect}")

      # 检查书名不能为空
      unless book_params[:title].present?
        flash[:alert] = "书名不能为空！"
        @logger.warn("书名为空，无法创建书籍")
        redirect_to new_book_path and return
      end

      # 检查数量格式
      unless valid_total?(book_params[:total])
        flash[:alert] = "数量必须是0到1000之间的整数！"
        @logger.warn("数量格式不正确，数量: #{book_params[:total]}")
        redirect_to new_book_path and return
      end

      # 查找作者和分类
      author = Author.find_by(id: book_params[:author_id])
      category = Category.find_by(id: book_params[:category_id])

      if author.nil?
        flash[:alert] = "请选择有效的作者！"
        @logger.warn("无效的作者ID: #{book_params[:author_id]}")
        redirect_to new_book_path and return
      end

      if category.nil?
        flash[:alert] = "请选择有效的分类！"
        @logger.warn("无效的分类ID: #{book_params[:category_id]}")
        redirect_to new_book_path and return
      end

      # 检查书籍是否已存在，如果作者名和书名相同表示已存在
      existing_book = Book.find_by(title: book_params[:title], author_id: author.id)

      if existing_book
        flash[:alert] = "这本书已经存在，请重新输入"
        @logger.warn("书籍已存在，书名: #{book_params[:title]}, 作者ID: #{author.id}")
        redirect_to new_book_path and return
      end

      # 创建新书籍
      @book = Book.new(
        title: book_params[:title],
        total: book_params[:total],
        description: book_params[:description],
        author_id: author.id,
        category_id: category.id
      )

      if @book.save
        @logger.info("书籍创建成功，书籍ID: #{@book.id}, 书名: #{@book.title}")
        redirect_to books_path, notice: '书籍添加成功！'
      else
        flash[:alert] = @book.errors.full_messages.join(", ")
        @logger.error("书籍创建失败，错误信息: #{@book.errors.full_messages.join(', ')}")
        redirect_to new_book_path
      end
    rescue => e
      @logger.error("创建书籍时发生错误，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end



  def destroy
    @book = Book.find(params[:id])

    begin
      @logger.info("开始删除书籍，书籍ID: #{@book.id}, 书名: #{@book.title}")

      # 检查该书籍是否有未归还的借阅记录
      if @book.borrowings.where(status: 0).any?
        @logger.warn("书籍ID: #{@book.id} 有未归还的借阅记录，无法删除")
        redirect_to books_path, alert: "该书籍有未归还的借阅记录，无法删除！"
        return
      end

      # 获取该书籍的 author_id 和 category_id
      author_id = @book.author_id
      category_id = @book.category_id

      # 删除书籍
      if @book.destroy
        @logger.info("书籍ID: #{@book.id} 删除成功")
      else
        @logger.error("书籍ID: #{@book.id} 删除失败")
      end

      # 如果该作者没有其他书籍，删除该作者
      if Book.where(author_id: author_id).empty?
        author = Author.find(author_id)
        if author.destroy
          @logger.info("作者ID: #{author.id} 删除成功")
        else
          @logger.error("作者ID: #{author.id} 删除失败")
        end
      end

      # 如果该分类没有其他书籍，删除该分类
      if Book.where(category_id: category_id).empty?
        category = Category.find(category_id)
        if category.destroy
          @logger.info("分类ID: #{category.id} 删除成功")
        else
          @logger.error("分类ID: #{category.id} 删除失败")
        end
      end

      redirect_to books_path, notice: '书籍删除成功！'
    rescue => e
      @logger.error("删除书籍时发生错误，书籍ID: #{@book.id}, 错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end



  def search
    # 使用 Ransack 创建查询对象
    @q = Book.ransack(params[:q])

    begin
      # @logger.info("开始搜索书籍，查询条件: #{@q.inspect}")
    # 获取查询结果，确保选择了作者的年龄字段@q.result.joins(:author)通过外键关联books表和author表
    @books = @q.result.joins(:author).select('books.*, authors.age AS author_age')  # 显式选择作者年龄字段
      #@logger.info("查询到的书籍数量: #{@books.count}")

    # 如果输入了年龄范围，进行年龄筛选并按年龄从大到小排序
    if params[:q][:author_age_gteq].present? || params[:q][:author_age_lteq].present?
      #@logger.info("应用了年龄范围筛选，最小年龄: #{params[:q][:author_age_gteq]}, 最大年龄: #{params[:q][:author_age_lteq]}")
      # 根据最小和最大年龄过滤作者
      @books = @books.where("authors.age >= ?", params[:q][:author_age_gteq]) if params[:q][:author_age_gteq].present?
      @books = @books.where("authors.age <= ?", params[:q][:author_age_lteq]) if params[:q][:author_age_lteq].present?

      # 按照作者的年龄降序排序
      @books = @books.order("authors.age DESC")
      # @logger.info("按照作者年龄降序排序")
    end

    # 排序：按书名排序
    @books = @books.order_by_title
      # @logger.info("按书名排序")

    # 分页
    @books = @books.page(params[:page]).per(3)
      # @logger.info("分页，当前页: #{params[:page]}, 每页显示: 3")

    # 如果没有找到书籍，显示提示信息并跳转回 books 页面
    if @books.empty?
      # @logger.info("未找到符合条件的书籍")
      flash[:alert] = "没有找到符合搜索条件的书籍。"
      redirect_to books_path
    else
      #@logger.info("成功查询到书籍，数量: #{@books.count}")
      render :index
    end

    rescue => e
        @logger.error("搜索书籍时发生错误，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end

  def borrow
    # 开启事务，确保操作的原子性
    ActiveRecord::Base.transaction do
      # 使用 `lock` 进行行级锁，防止并发借阅
      book = Book.lock.find_by(id: params[:id])

      unless book
        @logger.warn("借阅失败：书籍不存在，书籍ID: #{params[:id]}")
        redirect_to books_path, alert: "书籍不存在！"
        return
      end

      # 检查用户是否已经借阅过这本书且状态为借阅中
      existing_borrowing = Borrowing.find_by(user: current_user, book: book, status: 0)
      if existing_borrowing
        @logger.info("用户 #{current_user.id} 已经借阅过这本书，书籍ID: #{book.id}")
        redirect_to books_path, alert: "您已经借阅过这本书！"
        return
      end

      # 检查书籍库存是否足够
      if book.total <= 0
        @logger.warn("借阅失败：书籍库存不足，书籍ID: #{book.id}")
        redirect_to books_path, alert: "《#{book.title}》库存不足，无法借阅！"
        return
      end

      # 创建借阅记录
      Borrowing.create(user: current_user, book: book, borrowed_at: Time.current, status: 0)
      @logger.info("成功借阅书籍，用户ID: #{current_user.id}, 书籍ID: #{book.id}")

      # 更新书籍库存
      book.update!(total: book.total - 1)
      @logger.info("更新书籍库存，书籍ID: #{book.id}, 新库存: #{book.total}")

      redirect_to books_path, notice: "借阅成功！"
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      @logger.error("借阅失败，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
      redirect_to books_path, alert: "借阅失败，请稍后重试！"
    end
  end



  def return
    # 查找当前用户借阅的这本书，且状态为借阅中（status: 0）
    borrowing = Borrowing.find_by(user: current_user, book_id: params[:id], status: 0)

    # 如果没有借阅记录或已经归还（status: 1），则提示已还书
    if borrowing.nil? || borrowing.status == 1
      @logger.info("归还失败：用户 #{current_user.id} 已经归还过这本书，书籍ID: #{params[:id]}")
      redirect_to books_path, alert: "您已经还过这本书！"
      return
    end

    # 执行归还操作，修改归还时间和状态
    borrowing.update!(returned_at: Time.current, status: 1)  # 标记为已归还
    @logger.info("成功归还书籍，用户ID: #{current_user.id}, 书籍ID: #{borrowing.book.id}")

    # 修改书籍数量，归还一本书则增加库存
    book = borrowing.book
    book.update!(total: book.total + 1)
    @logger.info("更新书籍库存，书籍ID: #{book.id}, 新库存: #{book.total}")

    # 提示归还成功
    redirect_to books_path, notice: "书籍已成功归还！"
  end



  private

  def book_params
    params.require(:book).permit(:title, :author_id, :category_id,:total, :description)
  end

  # 🔹 辅助方法：验证作者类型（字符串或整数，且最多 10 个字符）
  def valid_author?(author_name)
    return false if author_name.nil? ||author_name.to_s.length > 10 || author_name.to_s.empty?
    author_name.is_a?(String) || author_name.to_s.match?(/^\d+$/)  # 允许字符串或整数
  end

  # 🔹 辅助方法：验证分类类型（只能是字符串，最多 10 个字符）
  def valid_category?(category_name)
    category_name.is_a?(String) && !category_name.match?(/\A\d+\z/)  && category_name.length <= 10 && !category_name.empty?
  end

  # 🔹 辅助方法：验证总数量（必须是 1~1000 之间的整数）
  def valid_total?(total)
    total.to_s.match?(/^\d+$/) && (0..1000).include?(total.to_i)
  end
end
