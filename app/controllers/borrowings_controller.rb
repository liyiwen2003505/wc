class BorrowingsController < ApplicationController
  before_action :require_login
  before_action :validate_page_param, only: [:index]
  before_action :parse_date_params, only: [:index]

  require 'logger'

  def index
    @logger.info("用户 #{current_user.id} 正在访问借阅记录页面")
    #获取当前登陆用户的所有登录记录
    @q = current_user.borrowings.ransack(params[:q])
    #返回所有满足查询条件的所有借阅记录
    @borrowings = @q.result
                    .ordered_by_time_and_book_name # 应用排序逻辑
                    .page(params[:page]).per(10)
    @logger.info("查询到 #{ @borrowings.size } 条借阅记录")

    # 校验页码
    if params[:page].to_i > @borrowings.total_pages && @borrowings.total_pages > 0
      @logger.warn("用户 #{current_user.id} 访问了不存在的页码: #{params[:page]}")
      redirect_to borrowings_path(page: 1), alert: "您访问的页码不存在！"
    else
      @logger.info("当前页码: #{params[:page] || 1}")
    end
  end


  private
  # 将日期字符串转换为 Date 类型并校验日期格式
  def parse_date_params
    params[:q] ||= {} # 如果 params[:q] 不存在，则初始化为空

    # 处理开始时间和结束时间
    [:borrowed_at_gteq, :borrowed_at_lteq].each do |key|
      if params[:q][key].present?
        begin
          @logger.info("正在处理 #{key} 日期: #{params[:q][key]}") # 记录用户传入的日期
          # 尝试使用 Date.parse 解析日期
          parsed_date = Date.parse(params[:q][key])
          if parsed_date.year > 9999 || parsed_date.year < 1000
            @logger.warn("日期 #{params[:q][key]} 解析后不在合理范围内，设为 nil") # 记录日期范围问题
            params[:q][key] = nil
          else
          # 根据字段类型设置时间：开始时间设置为当天的开始时间，结束时间设置为当天的结束时间
          params[:q][key] = key == :borrowed_at_gteq ? parsed_date.beginning_of_day : parsed_date.end_of_day
          @logger.info("#{key} 日期解析成功: #{params[:q][key]}") # 成功日志
          end
        rescue => e
          @logger.error("#{key} 日期解析失败，错误信息: #{e.message}\n#{e.backtrace.join("\n")}") # 记录错误信息
          # 捕获所有可能的异常，统一返回错误提示
          # redirect_to borrowings_path, alert: "#{key == :borrowed_at_gteq ? '开始' : '结束'}时间格式不正确，请重新输入！"
        end
      end
    end
  end



  def require_login
    unless current_user
      flash[:alert] = "请先登录后再查看借阅记录！"
      redirect_to new_session_path
    end
  end

  def validate_page_param
    if params[:page] && !params[:page].match?(/^\d+$/)
      redirect_to borrowings_path(page: 1), alert: "无效的页码！"
    end
  end
end
