require "test_helper"
require 'mocha/minitest'

  class AuthorsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @valid_author_params = {
        name: "张三",
        gender: "男",
        age: 30,
        description: "这是一个很好的作者",
        id_number: "123456789012345678",
        avatar: fixture_file_upload('2.jpg', 'image/jpeg')
      }
      @invalid_author_params = {
        name: "李四",
        age: 30,
        description: "这是一个很长很长的描述，这个会超过50个字符的",
        id_number: "123212321232123210",
        avatar: fixture_file_upload('6.jpg', 'image/jpeg')
      }
    end

    test "should create author with valid params" do
      assert_difference('Author.count', 1) do
        post authors_path, params: { author: @valid_author_params }
      end
      assert_redirected_to authors_path
      follow_redirect!
      assert_select 'div.flash-notice', '作者添加成功！'
    end

    test "should not create author with invalid name" do
      @invalid_author_params[:name] = ""
      post authors_path, params: { author: @invalid_author_params }
      assert_response :unprocessable_entity
      assert_select 'div.alert', '作者名称不能为空！'
    end

    test "should not create author with invalid age" do
      @invalid_author_params[:age] = -1
      post authors_path, params: { author: @invalid_author_params }
      assert_response :unprocessable_entity
      assert_select 'div.alert', '年龄必须在0到120之间并且不能为空！'
    end

    test "should not create author with invalid id_number" do
      @invalid_author_params[:id_number] = "12345"
      post authors_path, params: { author: @invalid_author_params }
      assert_response :unprocessable_entity
      assert_select 'div.alert', '身份证号不能为空且必须为18位！'
    end

    test "should not create author with invalid avatar format" do
      @invalid_author_params[:avatar] = fixture_file_upload('invalid_file.txt', 'text/plain')
      post authors_path, params: { author: @invalid_author_params }
      assert_response :unprocessable_entity
      assert_select 'div.alert', '只允许上传 JPG、PNG 或 GIF 格式的图片'
    end

    test "should not create author with avatar size greater than 600KB" do
      # 使用大于600KB的头像图片来测试
      @invalid_author_params[:avatar] = fixture_file_upload('6.jpg', 'image/jpeg')
      post authors_path, params: { author: @invalid_author_params }
      assert_response :unprocessable_entity
      assert_select 'div.alert', '头像大小不能超过 600KB'
    end

    test "should not create author if id_number already exists" do
      # 首先创建一个已经存在的作者
      Author.create(@valid_author_params)

      # 然后尝试创建相同身份证号的作者
      post authors_path, params: { author: @valid_author_params }
      assert_response :unprocessable_entity
      assert_select 'div.alert', '身份证号已存在！'
    end

    test "should log error and render new if exception occurs" do
      # 模拟抛出一个异常
      Author.any_instance.stubs(:save).raises(StandardError.new("Something went wrong"))
      post authors_path, params: { author: @valid_author_params }
      assert_response :unprocessable_entity
      assert_select 'div.alert', '无法保存作者，请检查输入信息。'
    end
  end