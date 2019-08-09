class PasswordController < ApplicationController
  include MailHelper

  get '/forgot_password' do 
    erb:'forgot_password.html'
  end

  post '/forgot_password' do
    settings.log.info(params)
    a = User.where(equality: {email: params[:email]})
    if a.any? && a[0].is_a?(User)
        rand_hash = rand(36**52).to_s(36)
        #reset_mail(a[0].email, rand_hash)
        a[0].email = rand_hash
        p a[0].save
    end
end
end
