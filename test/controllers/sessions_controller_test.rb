require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # 确保在 fixtures 中定义了一个用户
    @valid_password = '1234'  # 正确的密码
  end

  test "should log in with valid credentials" do
    post sessions_path, params: { email: @user.email, password: @valid_password }
    assert_redirected_to root_path  # 检查是否重定向到首页
    follow_redirect!
    assert_select "div.flash-notice", "登陆成功!"
  end

  test "should not log in with invalid email" do
    post sessions_path, params: { email: 'wrong@example.com', password: @valid_password }
    assert_template :new
    assert_select "div.alert", "换一个email或password"
  end

  test "should not log in with invalid password" do
    post sessions_path, params: { email: @user.email, password: 'wrongpassword' }
    assert_template :new
    assert_select "div.alert", "换一个email或password"
  end

  test "should log out" do
    # 登录
    post sessions_path, params: { email: @user.email, password: @valid_password }
    assert_redirected_to root_path
    follow_redirect!

    # 退出
    delete destroy_sessions_path  # 使用 destroy_sessions_path 进行登出
    assert_redirected_to root_path  # 检查是否重定向到首页
    follow_redirect!
    assert_select "div.flash-notice", "退出成功!"
  end
end

