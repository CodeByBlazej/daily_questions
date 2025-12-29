class TodayController < ApplicationController
  before_action :authenticate_user!

  def show
    @users = User.order(:id).to_a

    if @users.size != 2
      @message = "This app expects exactly 2 users. Current: #{@users.size}."
      return
    end

    @open_assignment = DailyAssignment.open.order(created_at: :desc).first

    # If nothing is open (first run OR ran out of questions earlier), try to create the next one.
    if @open_assignment.nil?
      next_recipient = next_recipient_when_none_open(@users)
      giver = other_user(next_recipient)

      @open_assignment = create_next_assignment(recipient: next_recipient, giver: giver)
      if @open_assignment.nil?
        @message = "No questions available yet. Add some in “Your questions”."
        return
      end
    end

    if @open_assignment.recipient == current_user
      @assignment = @open_assignment
    else
      @waiting_on = @open_assignment.recipient
      @message = "Waiting for #{@waiting_on.name} to answer 🙂"
    end
  end

  private

  def other_user(user)
    (@users - [ user ]).first
  end

  def next_recipient_when_none_open(users)
    last = DailyAssignment.order(created_at: :desc).first
    return users.first if last.nil?

    # alternate turns: next recipient is the other person
    (users - [ last.recipient ]).first
  end

  def create_next_assignment(recipient:, giver:)
    seen_ids = DailyAssignment.where(recipient: recipient).select(:question_id)
    question = Question.where(author: giver).where.not(id: seen_ids).order(Arel.sql("RANDOM()")).first
    return nil if question.nil?

    DailyAssignment.create!(
      recipient: recipient,
      question: question,
      assigned_at: Time.current
    )
  end
end
