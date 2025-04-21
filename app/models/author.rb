class Author < ApplicationRecord
  has_many :books
  mount_uploader :avatar, AvatarUploader

  before_save :set_avatar_size

  validates :name, presence: true, length: { maximum: 10 }
  validates :gender, presence: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }
  validates :description, length: { maximum: 50 }
  validates :id_number, presence: true, length: { is: 18 }, uniqueness: true, numericality: { only_integer: true }

  # 允许 Ransack 搜索的字段
  def self.ransackable_attributes(auth_object = nil)
    %w[name age gender id_number description]
  end

  def set_avatar_size
    if avatar.present?
      self.avatar_size = avatar.size / 1024  # 存储为 KB
    end
  end
end
