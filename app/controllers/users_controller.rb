class UsersController < ApplicationController

  # 处理头像更新
  def new
    @user = User.new
  end





  def create
    @user = User.new(user_params)

    # 记录用户注册的尝试
    @logger.info("尝试注册用户，输入的email: #{params[:user][:email]}")

    # 手动检查密码是否匹配
    if params[:user][:password] != params[:user][:password_confirmation]
      # 记录密码不一致的错误
      @logger.warn("用户 #{params[:user][:email]} 注册失败，原因: 两次输入的密码不一致")

      flash.now[:alert] = "两次输入的密码不一致！"
      return render :new  # 重新渲染页面
    end

    # 检查密码是否为空
    if @user.password.blank? || @user.password_confirmation.blank?
      # 记录密码为空的错误
      @logger.warn("用户 #{params[:user][:email]} 注册失败，原因: 密码为空")

      flash.now[:alert] = "输入信息不能为空！"
      return render :new  # 重新渲染页面
    end

    if @user.save  # 如果用户符合条件，保存到数据库
      # 记录用户注册成功
      # @logger.info("用户 #{params[:user][:email]} 注册成功，用户ID: #{@user.id}")

      # session[:user_id] = @user.id  # 记录该用户 ID
      # redirect_to new_session_path, notice: "注册成功"  # 注册成功后跳转到登录页面
    else
      # 记录用户保存失败的原因
      @logger.error("用户 #{params[:user][:email]} 注册失败，原因: #{@user.errors.full_messages.to_sentence}")

      flash.now[:alert] = @user.errors.full_messages.to_sentence
      return render :new
    end
  end



  private
  #过滤用户提交的参数
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
