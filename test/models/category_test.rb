require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "should not save category without name" do
    category = Category.new
    assert_not category.save, "Saved the category without a name"
  end

  test "should not save category with duplicate name" do
    Category.create!(name: "小说")
    duplicate = Category.new(name: "小说")
    assert_not duplicate.save, "Saved the category with a duplicate name"
  end

  test "should not save category with a name longer than 10 characters" do
    category = Category.new(name: "这是一个非常非常长的分类名称")
    assert_not category.save, "Saved the category with a name longer than 10 characters"
  end

  test "should save category with valid name" do
    category = Category.new(name: "科技")
    assert category.save, "Couldn't save a valid category"
  end
end
