class Book < ApplicationRecord
  belongs_to :author
  belongs_to :category
  has_many :borrowings, dependent: :destroy
  has_many :users, through: :borrowings

    # 定义一个 scope，按 title 字段升序排序
    scope :order_by_title, -> { order(:title) }


  validates :title,
            presence: { message: "标题不能为空" },
            length: { maximum: 20, message: "标题不能超过20个字符" }

  # 允许 Ransack 搜索的属性
  def self.ransackable_attributes(auth_object = nil)
    # 返回可以搜索的字段列表
    ["id", "title", "author_id", "category_id", "created_at", "updated_at"]
  end

  # 可选：自定义作者年龄搜索
  def self.ransackable_associations(auth_object = nil)
    # 返回可以被 Ransack 查询的关联
    ["author", "category"]
  end
end
