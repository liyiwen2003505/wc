# require "test_helper"
#
# class UsersControllerTest < ActionController::TestCase
#   setup do
#     # 创建测试用的用户
#     @user = users(:one)  # 确保在fixtures中有一位用户
#   end
#
#   test "should get new" do
#     get new_user_path
#     assert_response :success
#   end
#
#   test "should create user with valid parameters" do
#     assert_difference('User.count', 1) do
#       post users_path, params: {
#         user:
#           { name: "Test User",
#             email: "testuser@example.com",
#             password: "password123",
#             password_confirmation: "password123"
#           }
#       }
#     end
#
#     user = User.find_by(email: "testuser@example.com")
#     assert_equal user.id, session[:user_id]  # ✅ 这就能检测到了
#     assert_redirected_to new_session_path
#   end
#
#   test "should not create user with invalid password confirmation" do
#     assert_no_difference('User.count') do
#       post users_path, params: { user: { name: "Test User", email: "testuser@example.com", password: "password123", password_confirmation: "wrongpassword" } }
#     end
#     assert_template :new
#     assert_select "div.alert", "两次输入的密码不一致！"
#   end
#
#   test "should not create user with blank password" do
#     assert_no_difference('User.count') do
#       post users_path, params: { user: { name: "Test User", email: "testuser@example.com", password: "", password_confirmation: "" } }
#     end
#     assert_template :new
#     assert_select "div.alert", "输入信息不能为空！"
#   end
#
#   test "should not create user with invalid email" do
#     assert_no_difference('User.count') do
#       post users_path, params: { user: { name: "Test User", email: "invalidemail", password: "password123", password_confirmation: "password123" } }
#     end
#     assert_template :new
#     assert_select "div.alert", /Email 格式不正确/  # 确保你的 User 模型有类似的验证
#   end
# end


require "test_helper"

class UsersControllerTest < ActionController::TestCase
  setup do
    # 创建测试用的用户
    @user = users(:one)  # 确保在fixtures中有一位用户
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user with valid parameters" do
    assert_difference('User.count', 1) do
      post :create, params: {
        user: {
          name: "Test User",
          email: "testuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    # 检查 session[:user_id] 是否被正确设置
    user = User.find_by(email: "testuser@example.com")
    assert_equal user.id, @controller.session[:user_id]  # 确保 session 中的 user_id 被设置为新用户的 ID
    assert_redirected_to new_session_path  # 确保页面被重定向到登录页面
  end

  test "should not create user with invalid password confirmation" do
    assert_no_difference('User.count') do
      post :create, params: { user: { name: "Test User", email: "testuser@example.com", password: "password123", password_confirmation: "wrongpassword" } }
    end
    assert_template :new
    assert_select "div.alert", "两次输入的密码不一致！"
  end

  test "should not create user with blank password" do
    assert_no_difference('User.count') do
      post :create, params: { user: { name: "Test User", email: "testuser@example.com", password: "", password_confirmation: "" } }
    end
    assert_template :new
    assert_select "div.alert", "输入信息不能为空！"
  end

  test "should not create user with invalid email" do
    assert_no_difference('User.count') do
      post :create, params: { user: { name: "Test User", email: "invalidemail", password: "password123", password_confirmation: "password123" } }
    end
    assert_template :new
    assert_select "div.alert", /Email 格式不正确/  # 确保你的 User 模型有类似的验证
  end
end