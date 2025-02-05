class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :main, :map ]
  before_action :set_user, only: :user_profile

  def main
    @spots= Spot.all.includes(:user, :ratings).order("created_at DESC").first(6)
    @ratings = Rating.all.where.not(review_title: [ nil, "" ]).includes(:user, :spot).order("created_at DESC").first(6)

    render template: "pages/main"
  end


  def about
    render template: "pages/_about"
  end

  def user_profile
    @user
    @spotcount = Spot.where(user_id: @user.id).size
    @spots  = Spot.where(user_id: @user.id).includes(:ratings).first(100)
    @ratings = Rating.where(user_id: @user.id)
    render template: "pages/user_profile"
  end

  # def how_to
  #   render template: "pages/_how_to"
  # end
  #
  # def map
  #   render template: "pages/map"
  # end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
