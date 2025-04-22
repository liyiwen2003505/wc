class AuthorsController < ApplicationController
  before_action :validate_page_param, only: [:index]
  before_action :set_author, only: [:edit, :update]
  def index
    @logger.info("用户 #{current_user.id}正在访问作者信息界面")
    begin
    # 创建 Ransack 搜索对象，支持多条件搜索
    @q = Author.ransack(params[:q])  # 获取搜索条件

    @logger.info("搜索信息#{params[:q].inspect}")
    # 按照提供的搜索条件进行筛选
    @authors = @q.result
                 .order(:age)  # 按照年龄升序排序


    # 添加年龄范围过滤
       if params[:min_age].present?
         @authors = @authors.where("age >= ?", params[:min_age])
         @logger.info("添加最小年龄过滤条件: #{params[:min_age]}")
       end

       if params[:max_age].present?
         @authors = @authors.where("age <= ?", params[:max_age])
         @logger.info("添加最大年龄过滤条件: #{params[:max_age]}")
       end

       # 分页处理
       @authors = @authors.page(params[:page]).per(3)

       # 记录日志：查询到的作者数量
       @logger.info("查询到的作者数量: #{@authors.count}, 当前页: #{params[:page] || 1}")
    rescue => e
      # 记录异常日志
      logger.error("发生错误: #{e.message}\n异常发生位置: #{e.backtrace.join("\n")}")
    end


    # 响应请求
    respond_to do |format|
      format.html # 如果是 HTML 请求，默认渲染 index
      format.json do
        render json: {
          success: true,
          authors: @authors.map do |author|
            {
              id: author.id,
              name: author.name,
              age: author.age,
              id_number: author.id_number,
              description: author.description.presence || '暂无描述',
              gender: author.gender,
              avatar_url: author.avatar.url.present? ? request.base_url + author.avatar.url : nil
            }
          end,
          total_pages: @authors.total_pages # 返回总页数
        }
      end
    end
  end
  # # 创建 Ransack 搜索对象
    # @q = Author.ransack(params[:q]) #从请求中传来的参数
    # @authors = @q.result
    #              .order(:age)             # 🔹 只按年龄升序排序
    #              .page(params[:page])
    #              .per(3)
    #
    #
    #
    # respond_to do |format|
    #   format.html #如果请求时html格式 rails会默认渲染index
    #   format.json do
    #     render json: {
    #       success: true,
    #       #遍历所有符合条件作者
    #       authors: @authors.map do |author|
    #         {
    #           id: author.id,
    #           name: author.name,
    #           age: author.age,
    #           id_number: author.id_number,
    #           description: author.description.presence || '暂无描述',
    #           gender: author.gender,
    #           avatar_url: author.avatar.url.present? ? request.base_url + author.avatar.url : nil
    #         }
    #       end,
    #       total_pages: @authors.total_pages #返回总页数
    #     }
    #   end
    # end


  def new
    @author = Author.new
  end


  def show
    @author = Author.find(params[:id])
  end


  def create
    name = author_params[:name]
    @logger.info("正在创建作者，提交的名称为: #{name}")
    @author = Author.new(author_params)

    begin

    # 确保作者名称不为空
    if name.blank?
      flash.now[:alert] = "作者名称不能为空！"
      @logger.error("作者名称为空，无法创建作者")
      render :new, status: :unprocessable_entity and return
    end

    # 确保名字是字符串或整数，且包含字母、数字或中文字符，长度不超过 10
    unless (name.is_a?(String) || name.is_a?(Integer)) && name.to_s.length <= 10 && name.to_s.match?(/\A[\w\u4e00-\u9fa5]+\z/)
      @logger.error("作者名称格式错误，名称: #{name}")
      flash.now[:alert] = "输入格式错误：名字只能包含字母、数字或中文，且长度≤10！"
      render :new, status: :unprocessable_entity and return
    end

    # 确保年龄在0到120之间且不为空
    if @author.age.blank? || @author.age < 0 || @author.age > 100
      flash.now[:alert] = "年龄必须在0到60之间并且不能为空！"
      @logger.error("作者年龄不在有效范围内，年龄: #{@author.age}")
      render :new, status: :unprocessable_entity and return
    end

    # 确保详情字段不超过50个字符
    description = author_params[:description]
    if description.length > 50
      flash.now[:alert] = "详情字段不能超过50个字符！"
      @logger.error("作者详情字段长度超过限制，详情: #{description}")
      render :new, status: :unprocessable_entity and return
    end

    # 确保身份证号是18位且不能为空
    id_number = author_params[:id_number]
    if id_number.blank? || id_number.length != 18
      flash.now[:alert] = "身份证号不能为空且必须为18位！"
      @logger.error("身份证号格式不正确，身份证号: #{id_number}")
      render :new, status: :unprocessable_entity and return
    end

    # 检查身份证号是否已经存在
    if Author.exists?(id_number: id_number)
      flash.now[:alert] = "身份证号已存在！"
      @logger.error("身份证号已存在，身份证号: #{id_number}")
      render :new, status: :unprocessable_entity and return
    end

    # 头像验证
    if params[:author][:avatar].present?
      uploaded_file = params[:author][:avatar]

      # 确保头像文件是合法的格式（例如：JPG, PNG, GIF）
      allowed_formats = ['image/jpeg', 'image/png', 'image/gif']
      unless allowed_formats.include?(uploaded_file.content_type)
        flash.now[:alert] = "只允许上传 JPG、PNG 或 GIF 格式的图片"
        @logger.error("头像格式不符合要求，文件类型: #{uploaded_file.content_type}")
        render :new, status: :unprocessable_entity and return
      end

      # 确保头像大小不超过600kb
      max_size_in_kb = 600
      if uploaded_file.size > max_size_in_kb * 1024
        flash.now[:alert] = "头像大小不能超过 #{max_size_in_kb}KB"
        @logger.error("头像文件过大，文件大小: #{uploaded_file.size / 1024}KB")
        render :new, status: :unprocessable_entity and return
      end

      # 保存头像文件（确保头像上传后，先保存作者数据以生成 ID）
      if @author.save
        # 上传头像
        @author.avatar = uploaded_file
        # 获取文件的原始名称
        filename = uploaded_file.original_filename
        # 更新头像文件名
        @author.update_column(:avatar, filename)
        # 保存图片大小
        @author.update_column(:avatar_size, uploaded_file.size / 1024)  # 图片大小，以 KB 为单位
        @logger.info("头像上传成功，文件名: #{filename}, 文件大小: #{uploaded_file.size / 1024}KB")
      else
        render :new, status: :unprocessable_entity and return
      end
    else
      flash.now[:alert] = "请上传头像"
      @logger.error("头像未上传")
      render :new, status: :unprocessable_entity and return
    end

    # 创建作者
    if @author.save
      @logger.info("作者创建成功，ID: #{@author.id}, 名称: #{name}")
      redirect_to authors_path, notice: "作者添加成功！"
    else
      flash.now[:alert] = "无法保存作者，请检查输入信息。"
      @logger.error("保存作者失败，原因: #{@author.errors.full_messages.join(', ')}")
      render :new , status: :unprocessable_entity
    end
    rescue => e
        @logger.error("创建作者时发生错误，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
        render :new, status: :unprocessable_entity
    end
  end


  def edit
    # 编辑作者页面的处理
  end

  def update
    @author = Author.find(params[:id])

    begin
      @logger.info("正在更新作者，作者ID: #{@author.id}, 当前页面: #{params[:page]}")
       # 🔹 确保作者名称不为空
       if author_params[:name].blank?
         flash.now[:alert] = "作者名称不能为空！"
         @logger.error("作者名称为空，无法更新，作者ID: #{@author.id}")
         render :edit, status: :unprocessable_entity and return
       end

       # 🔹 确保头像不能为空（如果之前没有头像）
       if params[:author][:avatar].blank? && @author.avatar.blank?
         flash.now[:alert] = "头像不能为空，请上传头像！"
         @logger.error("头像为空，无法更新，作者ID: #{@author.id}")
         render :edit, status: :unprocessable_entity and return
       end

       # 🔹 处理头像上传
       if params[:author][:avatar].present?
         uploaded_file = params[:author][:avatar]
         @logger.info("头像上传中，文件名: #{uploaded_file.original_filename}, 文件大小: #{uploaded_file.size / 1024}KB")

         # 🔹 验证文件格式（只允许 JPG, PNG, GIF）
         allowed_formats = ["image/jpeg", "image/png", "image/gif"]
         unless allowed_formats.include?(uploaded_file.content_type)
           flash.now[:alert] = "只允许上传 JPG、PNG 或 GIF 格式的图片"
           @logger.error("头像格式不符合要求，文件类型: #{uploaded_file.content_type}, 作者ID: #{@author.id}")
           render :edit, status: :unprocessable_entity and return
         end

         # 🔹 验证文件大小（不超过 700KB）
         max_size_kb = 700
         if uploaded_file.size > max_size_kb * 1024
           flash.now[:alert] = "头像大小不能超过 #{max_size_kb} KB"
           @logger.error("头像文件大小超过限制，文件大小: #{uploaded_file.size / 1024}KB, 作者ID: #{@author.id}")
           render :edit, status: :unprocessable_entity and return
         end

         # 🔹 更新头像
         # @logger.info("头像文件已通过验证，开始更新头像，作者ID: #{@author.id}")
         @author.avatar = uploaded_file
       end

       # 🔹 更新作者信息
      if @author.update(author_params)
        @logger.info("作者更新成功，作者ID: #{@author.id}")
        redirect_to authors_path(page: params[:page]), notice: "作者更新成功！"
      else
        flash.now[:alert] = "无法更新作者，请检查输入信息。"
        @logger.error("更新失败，验证失败，原因: #{@author.errors.full_messages.join(', ')}, 作者ID: #{@author.id}")
        render :edit, status: :unprocessable_entity
      end
    rescue => e
        @logger.error("更新作者时发生错误，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end


  def destroy
    # @author = Author.find(params[:id])
    #
    # if @author.books.exists?
    #   flash[:alert] = "该作者下仍有书籍，无法删除！"
    # else
    #   @author.destroy
    #   flash[:notice] = "作者已删除！"
    # end
    #
    # redirect_to authors_path

      @logger.info("尝试删除作者，作者ID: #{params[:id]}")

      @author = Author.find(params[:id])

      if @author.books.exists?
        flash[:alert] = "该作者下仍有书籍，无法删除！"
        @logger.warn("删除失败，作者ID: #{@author.id} 下有书籍，无法删除")
      else
        @author.destroy
        flash[:notice] = "作者已删除！"
        @logger.info("作者已删除，作者ID: #{@author.id}")
      end

      redirect_to authors_path
  end


  private

  def author_params
    params.require(:author).permit(:name, :gender, :age, :description, :id_number,:avatar, :avatar_size)
  end

  def set_author
    @author = Author.find(params[:id])
  end

  def validate_page_param
    # 如果 page 参数不是数字，则重定向到第一页并提示错误
    if params[:page] && !params[:page].match?(/^\d+$/)
      redirect_to authors_path(page: 1), alert: "无效的页码！"
    end
  end
end
