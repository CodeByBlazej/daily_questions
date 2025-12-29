class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  # Questions this user wrote
  has_many :authored_questions,
            class_name: "Question",
            foreign_key: :author_id,
            dependent: :destroy

  # Daily assignments this user received (questions shown to them)
  has_many :daily_assignments,
            foreign_key: :recipient_id,
            dependent: :destroy

  # Convenience: questions the user has received throught daily assignments
  has_many :received_questions, through: :daily_assignments, source: :question

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
