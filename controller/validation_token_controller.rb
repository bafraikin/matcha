class ValidationTokenController < ApplicationController

  def title
    "token"
  end

  namespace "/token" do
    get '/' do 
      erb:'login.html'
    end

    get '/validated_account' do
      settings.log.info(params)
      a = User.where(equality: {email_token: params[:token]})
      if  a.any?
        a[0].email_token = nil
        a[0].save #check ce que la fonction retourne pour pas avoir d'erreur
        flash[:success] = "Account validated"
        redirect "/registration/login"
      end
      flash[:error] = "invalid token"
      redirect "/registration/login"
    end

    get '/reset_password' do
      settings.log.info(params)
      a = User.where(equality: {reset_token: params[:token]})
      if a.any? && a[0].email_token == nil
        session[:current_user] = a[0]
        a[0].reset_token = nil
        a[0].save
        flash[:success] = "you can now modify your password on your profile"
        #add redirect to user profil
      end
      redirect "/"
    end
  end
end