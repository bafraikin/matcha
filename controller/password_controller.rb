class PasswordController < ApplicationController
  include MailHelper

  get '/forgot_password' do 
    erb:'forgot_password.html'
  end

  get '/reset_password' do
    unless params['token'].nil?
      erb:'reset_password.html'
    else 
       redirect not_found
    end
  end

  post '/forgot_password' do
    a = User.where(equality: {email: params[:email]})
    if a.any? && a[0].is_a?(User)
      rand_hash = rand(36**52).to_s(36)
      reset_mail(a[0].email, rand_hash)
      a[0].reset_token = rand_hash
      a[0].save
    end
    flash[:success] = "If you mail exist we sent you a mail"
    redirect '/'
  end
end
