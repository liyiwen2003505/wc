
class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book
  # borrowing.rb
  scope :ordered_by_time_and_book_name, -> {
    joins(:book)
      .order(borrowed_at: :desc) # 先按借阅时间倒序
      .order("books.title COLLATE utf8mb4_unicode_ci ASC") # 再按书名排序（拼音顺序）
  }


  validates :returned_at, comparison: { greater_than_or_equal_to: :borrowed_at, message: "归还时间不能早于借阅时间" }, if: :returned_at?
  # 如果需要可以指定可搜索的字段
  def self.ransackable_attributes(auth_object = nil)
    ["borrowed_at", "returned_at", "status", "book_id"]
  end
end
