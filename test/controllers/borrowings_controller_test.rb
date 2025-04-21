require "test_helper"
require "mocha/minitest"

class BorrowingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @book = Book.first || Book.create!(
      title: "测试书",
      total: 5,
      description: "描述",
      author: Author.first || Author.create!(name: "作者"),
      category: Category.first || Category.create!(name: "分类")
    )
    @borrowing = Borrowing.create!(user: @user, book: @book, borrowed_at: Time.current - 1.day)

    # 模拟用户登录
    BorrowingsController.any_instance.stubs(:current_user).returns(@user)
  end

  # test "should redirect when not logged in" do
  #   get borrowings_url
  #   assert_redirected_to new_session_path
  #   assert_equal "请先登录后再查看借阅记录！", flash[:alert]
  # end

  test "should get index when logged in" do
    # 获取所有借阅记录
    borrowings = Borrowing.all
    get borrowings_url

    borrowings.each do |borrowing|
      puts "Borrowing ID: #{borrowing.id}, Book: #{borrowing.book.title}, User: #{borrowing.user.email}, Borrowed at: #{borrowing.borrowed_at}"
    end

    assert_response :success
    assert_select "body", /借阅记录|Borrowing/i
  end

  test "should redirect if page param is invalid" do
    get borrowings_url(page: "abc")
    puts "Redirected to: #{response.location}"  # 打印重定向的 URL
    assert_redirected_to borrowings_path(page: 1)
    assert_equal "无效的页码！", flash[:alert]
  end

  test "should redirect if page number too large" do
    get borrowings_url(page: 1000)
    puts "Redirected to: #{response.location}"  # 打印重定向的 URL
    assert_redirected_to borrowings_path(page: 1)
    assert_equal "您访问的页码不存在！", flash[:alert]
  end

  test "should parse valid date params" do
    get borrowings_url(q: {
      borrowed_at_gteq: "2024-01-01",
      borrowed_at_lteq: "2025-12-31"
    })

    borrowings.each do |borrowing|
      puts "Borrowing ID: #{borrowing.id}, Book: #{borrowing.book.title}, User: #{borrowing.user.email}, Borrowed at: #{borrowing.borrowed_at}"
    end

    assert_response :success
  end

  test "should not crash with invalid date params" do
    get borrowings_url(q: { borrowed_at_gteq: "xxxx-xx-xx" })

    borrowings.each do |borrowing|
      puts "Borrowing ID: #{borrowing.id}, Book: #{borrowing.book.title}, User: #{borrowing.user.email}, Borrowed at: #{borrowing.borrowed_at}"
    end
    assert_response :success
  end
end
