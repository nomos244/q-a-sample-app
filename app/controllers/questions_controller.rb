class QuestionsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy, :solve]
  before_action :correct_user, only: [:edit, :update, :destroy, :solve]

  def index
    @questions = Question.order(created_at: :desc).page(params[:page]).per(5)
  end

  def solved
    @questions = Question.where(solved: true).order(created_at: :desc).page(params[:page]).per(5)
    render 'index'
  end

  def unsolved
    @questions = Question.where(solved: false).order(created_at: :desc).page(params[:page]).per(5)
    render 'index'
  end

  def new
    @question = current_user.questions.build
  end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      QaMailer.question_notification(@question).deliver_now
      flash[:success] = '質問を作成しました'
      redirect_to @question
    else
      flash.now[:danger] = '質問の作成ができませんでした'
      render 'new'
    end
  end

  def show
    @question = Question.find(params[:id])
    @answers = @question.answers
    @answer = current_user.answers.build if logged_in?
  end

  def edit
  end

  def update
    if @question.update(question_params)
      flash[:success] = '質問を更新しました'
      redirect_to questions_path
    else
      flash.now[:danger] = '質問の更新ができませんでした'
      render 'edit'
    end
  end

  def destroy
    @question.destroy
    flash[:success] = '質問を削除しました'
    redirect_to root_url
  end

  def solve
    if @question.update(solved: true)
      flash[:success] = '解決済みにしました'
      redirect_to question_path(@question)
    else
      flash.now[:danger] = '解決済みにできませんでした'
      render question_url(@question)
    end
  end

  private

    def correct_user
      @question = current_user.questions.find_by(id: params[:id])
      if @question.nil?
        flash[:danger] = '他のユーザの質問は編集できません'
        redirect_to root_url
      end
    end

    def question_params
      params.require(:question).permit(:title, :body)
    end

end
