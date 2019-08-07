class RegistrationController < ApplicationController
#	include MailHelper
	def title
		"registration"
	end

	namespace "/registration" do
		get '/login' do 
			erb:'login.html'
		end

		post '/registrate' do
			settings.log.info(params)
			if params[:user] && params[:user][:email]
				a = User.where(equality: {email: params[:user][:email]})
				if !(a.any? && a[0].good_password?(to_test: params[:user][:password]))
					flash[:error] = "WRONG CONNECTION"
					redirect to('registration/login')
				elsif a.any?
					session[:current_user] = a[0]
					flash[:success] = "Connection reussi"
					redirect "/"
				end
			end
		end

		get '/sign_up'do
			erb:'sign_up.html'
		end

		post "/create" do
			hash = params[:user]
			hash[:age]= hash[:age].to_i
			array = Array.new
			1.upto(2) do |i|
				symbol = ("interest" + i.to_s).to_sym
				array << hash.delete(symbol) if hash.key?(symbol)
			end
			hash.delete(:confirm_password)
			hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
			error = User.create(hash: hash.merge({interest: array, email_token: SecureRandom.hex}))
			if error.any? && !error[0].is_a?(User)
				flash[:error] = error.join('<br/>')
				redirect "/registration/sign_up"
			else
#				MailHelper.confirme_mail(hash[:email], hash[:email_token])
				flash[:success] = "Un email vous a ete envoyer"
				redirect "/"
			end
		end

	end
end
