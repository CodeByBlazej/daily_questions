class DailyAssignment < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :question

  validates :assigned_at, presence: true
  validates :question_id, uniqueness: { scope: :recipient_id } # matches your unique index

  scope :open, -> { where(answered_at: nil) }

  def answered?
    answered_at.present?
  end
end
