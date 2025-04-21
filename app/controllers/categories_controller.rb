class CategoriesController < ApplicationController
  before_action :validate_page_param, only: [:index]

  def index
    # 使用 Ransack 创建搜索对象
    @q = Category.ransack(params[:q])

    # 获取查询结果，分页每页5条记录
    @categories = @q.result.page(params[:page]).per(5)

    # 获取总页数
    total_pages = @categories.total_pages

    # 记录分页查询日志
    @logger.info("分页查询，当前页码: #{params[:page] || 1}, 总页数: #{total_pages}, 搜索条件: #{params[:q].inspect}")

    # 如果用户输入的页码超出范围，跳转到第一页并提示
    if params[:page].to_i > total_pages && total_pages > 0
      @logger.warn("用户请求的页码超出范围，页码: #{params[:page]}, 跳转到第一页")
      redirect_to categories_path(page: 1), alert: "您访问的页码不存在！"
    end
  end





  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    begin
      # 记录分类创建的初始信息
      @logger.info("尝试创建分类，输入的分类名称: #{@category.name}")

      if @category.name.blank?
        @logger.warn("分类名称为空，无法创建分类")
        flash.now[:alert] = "分类名称不能为空！"
        render :new, status: :unprocessable_entity
        return
      end

      if Category.exists?(name: @category.name)
        @logger.warn("分类名称已存在，无法创建分类: #{@category.name}")
        flash.now[:alert] = "分类已存在！"
        render :new, status: :unprocessable_entity
        return
      end

      # 检查分类名称是否只包含中文和字母，且长度不超过10
      unless @category.name.match?(/\A[\p{L}\p{Han}]+\z/) && @category.name.length <= 10
        @logger.warn("分类名称格式不正确，分类名称: #{@category.name}")
        flash.now[:alert] = "分类名称只能包含中文字符和字母，且长度不能超过 10！"
        render :new, status: :unprocessable_entity
        return
      end

      if @category.save
        @logger.info("分类创建成功，分类名称: #{@category.name}")
        redirect_to categories_path, notice: "分类添加成功！"
      else
        @logger.error("分类创建失败，错误信息: #{@category.errors.full_messages.join(', ')}")
        render :new, status: :unprocessable_entity
      end
    rescue => e
      # 捕获异常并记录错误信息
      @logger.error("创建分类时发生异常，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end




  def destroy
    @category = Category.find(params[:id])

    # 检查分类是否有书籍
    if @category.books.any?
      flash[:alert] = "该分类下有书籍，无法删除！"
    else
      @category.destroy
      flash[:notice] = "分类删除成功！"
    end

    redirect_to categories_path
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def validate_page_param
    # 如果 page 参数不是数字，则重定向到第一页并提示错误
    if params[:page] && !params[:page].match?(/^\d+$/)
      redirect_to categories_path(page: 1), alert: "无效的页码！"
    end
  end
end
