class User < ActiveRecord::Base
  has_secure_password
  
  has_many :reviews, dependent: :destroy  # เชื่อมกับ reviews และลบรีวิวเมื่อผู้ใช้ถูกลบ
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true
end
