require "test_helper"
require "mocha/minitest"


class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @book = books(:one)

    BooksController.any_instance.stubs(:current_user).returns(@user)

    @valid_params = {
      title: "测试书籍",
      description: "测试描述",
      total: 7,
      author_id: authors(:one).id,
      category_id: categories(:one).id
    }
  end

  test "should get index" do
    get books_url, headers: { 'HTTP_COOKIE' => "user_id=#{@user.id}" }
    assert_response :success
  end

  test "should show book" do
    get book_url(@book), headers: { 'HTTP_COOKIE' => "user_id=#{@user.id}" }
    assert_response :success
  end

  test "should redirect on invalid book ID" do
    get book_url("abc"), headers: { 'HTTP_COOKIE' => "user_id=#{@user.id}" }
    assert_redirected_to books_path
    assert_equal "书籍 ID 不合法！", flash[:alert]
  end

  test "should create book" do
    assert_difference("Book.count", 1) do
      post books_url, params: { book: @valid_params }, headers: { 'HTTP_COOKIE' => "user_id=#{@user.id}" }
    end

    assert_redirected_to books_path
    assert_equal "书籍添加成功！", flash[:notice]
  end

  test "should not create book with empty title" do
    post books_url, params: { book: @valid_params.merge(title: "") }, headers: { 'HTTP_COOKIE' => "user_id=#{@user.id}" }
    assert_redirected_to new_book_path
    assert_equal "书名不能为空！", flash[:alert]
  end

  test "should update book" do
    patch book_url(@book), params: { book: @valid_params.merge(title: "新标题") }, headers: { 'HTTP_COOKIE' => "user_id=#{@user.id}" }
    assert_redirected_to books_path
    assert_equal "书籍更新成功！", flash[:notice]
  end

  test "should delete book" do
    @book.borrowings.destroy_all
    assert_difference("Book.count", -1) do
      delete book_url(@book), headers: { 'HTTP_COOKIE' => "user_id=#{@user.id}" }
    end

    assert_redirected_to books_path
    assert_equal "书籍删除成功！", flash[:notice]
  end

  test "should borrow book" do
    post borrow_book_url(@book)
    assert_redirected_to books_url
    puts @book.reload.inspect
    puts Borrowing.where(user: @user, book: @book).pluck(:id, :status, :borrowed_at)
    assert_equal "借阅成功！", flash[:notice]
    assert_equal 4, @book.reload.total
  end

  test "should not borrow same book twice" do
    Borrowing.create!(user: @user, book: @book, status: 0, borrowed_at: Time.current)
    post borrow_book_url(@book)
    puts @book.reload.inspect
    puts Borrowing.where(user: @user, book: @book).pluck(:id, :status, :borrowed_at)

    assert_redirected_to books_url
    assert_equal "您已经借阅过这本书！", flash[:alert]
  end

  test "should return book" do
    Borrowing.create!(user: @user, book: @book, status: 0, borrowed_at: Time.current)
    post return_book_url(@book)
    puts @book.reload.inspect
    puts Borrowing.where(user: @user, book: @book).pluck(:id, :status, :borrowed_at)

    assert_redirected_to books_url
    assert_equal "书籍已成功归还！", flash[:notice]
    assert_equal 6, @book.reload.total
  end
end
