class UserMailer < ApplicationMailer
  default from: "info@vanspots.uk"

  def welcome_email
    @user = params[:user]
    @url  = "https://vanspots.uk/users/sign_in"
    mail(to: @user.email,
         from: "welcome@vanspots.uk",
         bcc: "vanspotsnewuser@purpleriver.dev",
         subject: "Welcome to VanSpots")
  end
end
