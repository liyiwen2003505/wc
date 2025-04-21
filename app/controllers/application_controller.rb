class ApplicationController < ActionController::Base
  helper_method :current_user#helper_method  让current_user成为一个辅助方法  它不仅可以在控制器中使用，还可以在视图中使用
  # 初始化 Logger，设置日志级别和输出目标
  before_action :initialize_logger


  private

  def current_user
    #如果@current_user存在就直接返回@current_user
    #否则执行后面的User.find_by(id: session[:user_id])：通过session[:user_id]从user表中查询对应用户
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def initialize_logger
    # 确保日志文件路径存在
    log_path = "log/development.log"
    @logger = Logger.new(log_path)
    @logger.level = Logger::DEBUG  # 设置日志级别
    @logger.formatter = proc do |severity, datetime, progname, msg|
      formatted_time = datetime.strftime('%Y-%m-%dT%H:%M:%S.%6N')  # 加 T 和微秒
      pid = Process.pid                                             # 当前进程号
      "[#{formatted_time} ##{pid}] #{severity} -- : #{msg}\n"
    end

  end
end

