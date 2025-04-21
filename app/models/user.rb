class User < ApplicationRecord
  has_secure_password
  has_many :borrowings
  has_many :books, through: :borrowings

  validates :name, presence: { message: "姓名不能为空" },
            uniqueness: { message: "姓名必须唯一" },
            length: { maximum: 7, message: "姓名不能超过7个字符" }

  validates :email, presence: { message: "邮箱不能为空" },
            uniqueness: { message: "邮箱必须唯一" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "邮箱格式不正确" },
            length: { maximum: 20, message: "邮箱不能超过20个字符" }

  validates :password, length: { maximum: 10, message: "密码不能超过10个字符" }
end
