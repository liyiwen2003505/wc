class SessionsController < ApplicationController

  def create
    begin
    # 根据表单输入的email查找用户
    @user = User.find_by(email: params[:email])

    # 记录登录尝试
    @logger.info("尝试登录，输入的email: #{params[:email]}")

    # 如果用户存在并且密码匹配
    if @user && @user.authenticate(params[:password])
      # 记录成功登录信息
      @logger.info("用户 #{params[:email]} 登录成功，用户ID: #{@user.id}")

      # 通过认证 当前用户id会被存储到session中，用户在浏览网站时保持登录状态直到会话结束
      session[:user_id] = @user.id
      redirect_to root_path, notice: '登陆成功!'
    else
      # 记录登录失败信息
      @logger.warn("用户 #{params[:email]} 登录失败，原因: 错误的密码或邮箱")

      flash.now[:alert] = '换一个email或password'
      # 重新输入登录信息
      render :new
    end
      rescue => e
        # 捕获异常并记录错误信息
        @logger.error("登录时发生异常，错误信息: #{e.message}\n#{e.backtrace.join("\n")}")
      end
  end


  def destroy
    #将存储在session中国的用户id删除  清楚当前用户会话
    session[:user_id] = nil
    redirect_to root_path,notice: '退出成功!'
  end
end
