class AssignmentsController < ApplicationController
  before_action :authenticate_user!

  def answer
    @users = User.order(:id).to_a
    assignment = DailyAssignment.find(params[:id])

    return head :forbidden unless assignment.recipient == current_user

    DailyAssignment.transaction do
      assignment.lock!

      # already answered in another tab? just bail nicely
      break if assignment.answered?

      assignment.update!(answered_at: Time.current)

      next_recipient = (@users - [ current_user ]).first
      giver = current_user

      # Create next assignment for the other person (if possible)
      seen_ids = DailyAssignment.where(recipient: next_recipient).select(:question_id)
      next_question = Question.where(author: giver).where.not(id: seen_ids).order(Arel.sql("RANDOM()")).first

      if next_question
        DailyAssignment.create!(
          recipient: next_recipient,
          question: next_question,
          assigned_at: Time.current
        )
      end
    end

    redirect_to today_path
  end
end
