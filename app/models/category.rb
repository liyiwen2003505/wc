class Category < ApplicationRecord
  has_many :books
  validates :name, presence: true, uniqueness: true, length: { maximum: 10 }

  # 显式声明哪些属性可以被 Ransack 搜索
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "created_at", "updated_at"]  # 你可以在这里列出你希望允许搜索的字段
  end
end
