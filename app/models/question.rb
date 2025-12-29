class Question < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :daily_assignments, dependent: :restrict_with_error

  validates :body, presence: true
end
