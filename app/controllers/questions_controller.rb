class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: :destroy

  def index
    @question = Question.new
    @questions = current_user.authored_questions.order(created_at: :desc)
  end

  def create
    @question = current_user.authored_questions.build(question_params)

    if @question.save
      redirect_to questions_path, notice: "Question added."
    else
      @questions = current_user.authored_questions.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    return head :forbidden unless @question.author == current_user

    if @question.destroy
      redirect_to questions_path, notice: "Deleted."
    else
      redirect_to questions_path, alert: @question.errors.full_messages.to_sentence
    end
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:body)
  end
end
