class Review < ActiveRecord::Base
  belongs_to :movie
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comments, presence: true
end
