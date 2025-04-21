# require "test_helper"
#
# class CategoriesControllerTest < ActionDispatch::IntegrationTest
#   setup do
#     @category = categories(:one) # 假设你已经有一个预先创建的 category fixture
#   end
#
#   # 测试获取分类列表
#   test "should get index" do
#     get categories_url
#     assert_response :success
#     assert_select "h1", "分类列表" # 假设页面中有个 h1 标签显示 "Categories"
#   end
#
#   # 测试分页功能，假设每页有 5 条记录
#   test "should get paginated categories" do
#     get categories_url(page: 2)
#     assert_response :success
#     assert_select "body", /Categories/i
#   end
#
#   # 测试页码无效时的重定向
#   test "should redirect when page param is invalid" do
#     get categories_url(page: "abc")
#     assert_redirected_to categories_path(page: 1)
#     assert_equal "无效的页码！", flash[:alert]
#   end
#
#   # 测试分类创建成功
#   test "should create category" do
#     assert_difference('Category.count') do
#       post categories_url, params: { category: { name: "新闻" } }
#     end
#     assert_redirected_to categories_path
#     assert_equal "分类添加成功！", flash[:notice]
#   end
#
#   # 测试分类创建失败（名称为空）
#   test "should not create category with empty name" do
#     assert_no_difference('Category.count') do
#       post categories_url, params: { category: { name: "" } }
#     end
#     assert_response :unprocessable_entity
#     assert_select "div.alert", "分类名称不能为空！"
#   end
#
#   # 测试分类创建失败（名称已存在）
#   test "should not create category with existing name" do
#     assert_no_difference('Category.count') do
#       post categories_url, params: { category: { name: @category.name } }
#     end
#     assert_response :unprocessable_entity
#     assert_select "div.alert", "分类已存在！"
#   end
#
#   # 测试分类创建失败（名称格式不正确）
#   test "should not create category with invalid name format" do
#     assert_no_difference('Category.count') do
#       post categories_url, params: { category: { name: "Invalid Name@123" } }
#     end
#     assert_response :unprocessable_entity
#     assert_select "div.alert", "分类名称只能包含中文字符和字母，且长度不能超过 10！"
#   end
#
#   # 测试分类删除失败（分类下有书籍）
#   test "should not destroy category with books" do
#     # 假设 @category 已有书籍
#     @category.books.create!(title: "Test Book", author: "Test Author", total: 1)
#
#     assert_no_difference('Category.count') do
#       delete category_url(@category)
#     end
#     assert_redirected_to categories_path
#     assert_equal "该分类下有书籍，无法删除！", flash[:alert]
#   end
# end


require 'test_helper'
require "mocha/minitest"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:one) # 假设你已经有一个预先创建的 category fixture
    @user = users(:one)
  end

  test "should get new" do
    # 访问 new 页面
    get new_category_url
    # 检查响应是否成功
    assert_response :success
    # 确保 @category 被正确初始化
    assert assigns(:category).is_a?(Category)
  end

  # 测试获取分类列表
  test "should get index" do
    get categories_url
    assert_response :success
    assert_select "h1", "分类列表" # 假设页面中有个 h1 标签显示 "Categories"
  end

  # 测试分页功能，假设每页有 5 条记录
  test "should get paginated categories" do
    get categories_url(page: 2)
    assert_response :success
    assert_select "body", /Categories/i
  end

  # 测试页码无效时的重定向
  test "should redirect when page param is invalid" do
    get categories_url(page: "abc")
    assert_redirected_to categories_path(page: 1)
    assert_equal "无效的页码！", flash[:alert]
  end

  # 测试分类创建成功
  test "should create category" do
    assert_difference('Category.count') do
      post categories_url, params: { category: { name: "新闻" } }
    end
    assert_redirected_to categories_path
    assert_equal "分类添加成功！", flash[:notice]
  end

  # 测试分类创建失败（名称为空）
  test "should not create category with empty name" do
    assert_no_difference('Category.count') do
      post categories_url, params: { category: { name: "" } }
    end
    assert_response :unprocessable_entity
    assert_select "div.alert", "分类名称不能为空！"
  end

  # 测试分类创建失败（名称已存在）
  test "should not create category with existing name" do
    assert_no_difference('Category.count') do
      post categories_url, params: { category: { name: @category.name } }
    end
    assert_response :unprocessable_entity
    assert_select "div.alert", "分类已存在！"
  end

  # 测试分类创建失败（名称格式不正确）
  test "should not create category with invalid name format" do
    assert_no_difference('Category.count') do
      post categories_url, params: { category: { name: "Invalid Name@123" } }
    end
    assert_response :unprocessable_entity
    assert_select "div.alert", "分类名称只能包含中文字符和字母，且长度不能超过 10！"
  end

  # 测试分类删除失败（分类下有书籍）
  test "should not destroy category with books" do
      author = Author.create!(
        name: "王小",
        gender: "男",
        age: 30,
        description: "Test Description",
        id_number: "122121233432343234",
        avatar: fixture_file_upload("2.jpg", "image/jpeg")
      )
    # 假设 @category 已有书籍
    @category.books.create!(title: "Test Book", author: author, total: 1)

    assert_no_difference('Category.count') do
      delete category_url(@category)
    end
    assert_redirected_to categories_path
    assert_equal "该分类下有书籍，无法删除！", flash[:alert]
  end

end

