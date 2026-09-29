# frozen_string_literal: true

class UsersController < ActionController::Base
  layout 'application'

  def index
    @user = User.first!
    render :show
  end

  def show
    @user = User.find(params[:id])
  end

  def playground
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user }
        format.json { render json: @user.as_json(include: :websites) }
      else
        format.html { render :show, status: 422 }
        format.json { render json: @user.errors, status: 422 }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :title, :role, :bio, websites_attributes: %i[id url])
  end
end
