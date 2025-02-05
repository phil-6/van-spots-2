class Admin::UsersController < ApplicationController
  before_action :authorize_admin
  before_action :set_user, except: [ :index, :sign_out_all ]

  def index
    render template: "admin/users"
  end

  def sign_out_all
    User.all.each do |user|
      sign_out user
    end
  end

  private


  def set_user
    @user = User.find(params[:id])
  end

  def authorize_admin
    redirect_to(root_path) unless current_user && current_user.admin?
  end
end
