class ValidationTokenController < ApplicationController

  def title
    "token"
  end

  namespace "/token" do

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

    post '/reset_password' do
      settings.log.info(params)
      user_to_reset = User.where(equality: {reset_token: params[:user][:token_password]})
      if user_to_reset.any? && user_to_reset[0].account_validated? 
        user_to_reset[0].password = params[:user][:password]
        error = User.validator(hash: user_to_reset[0].to_hash)
        if error.any? || params[:user][:password] != params[:user][:confirm_password]
          flash[:error] = User.error_message(array: error).join("\n")
          redirect '/reset_password?token=' + params[:user][:token_password]
          halt
        else
          user_to_reset[0].password = User.hash_password(password: params[:user][:password])
          user_to_reset[0].reset_token = nil
          user_to_reset[0].save
        end
      else
        flash[:error] = "go home you're drunk"
        redirect "/"
      end
      redirect "/"
    end
  end
end
