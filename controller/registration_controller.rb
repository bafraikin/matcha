class RegistrationController < ApplicationController
	include RegistrationHelper
	include MailHelper
	def title
		"registration"
	end

	namespace "/registration" do
		get '/login' do 
			block_logged_in
			erb:'login.html'
		end

		post '/registrate' do
			settings.log.info(params)
			block_logged_in
			if params[:user] && params[:user][:email]
				a = User.where(equality: {email: params[:user][:email]})
				if !(a.any? && a[0].good_password?(to_test: params[:user][:password]))
					flash[:error] = "WRONG CONNECTION"
					redirect to('registration/login')
				elsif a.any?
					session[:current_user] = a[0]
					save_if_valide_coordinate(params[:user][:latitude], params[:user][:longitude])
					flash[:success] = "Connection reussi"
					redirect "/"
				end
			end
		end

		get '/sign_up'do
			block_logged_in
			erb:'sign_up.html'
		end

		get '/sign_out' do
			block_unsigned
			session.clear
			flash[:success] = "Deconnecter avec succes"
			redirect "/"
		end

		post "/create" do
			hash = params[:user]
			hash[:age]= hash[:age].to_i
			array = Array.new
			0.upto(User.gender_pool.size) do |i|
				symbol = ("interest" + i.to_s).to_sym
				array << hash.delete(symbol) if hash.key?(symbol)
			end
			hash.delete(:confirm_password)
			hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
			check_user_email_already_used(email: hash[:email])
			error = User.create(hash: hash.merge({interest: array, email_token: SecureRandom.hex}))
			if error.any? && !error[0].is_a?(User)
				flash[:error] = error.join('<br/>')
				redirect "/registration/sign_up"
			else
				confirme_mail(hash[:email], error[0].email_token)
				flash[:success] = "Un email vous a ete envoyer"
				redirect "/"
			end
		end

	end
	private
	def check_user_email_already_used(email:)
		if email && User.where(equality: {email: email}).any?
			flash[:error] = "email already used"
			redirect "/registration/sign_up"
		end
	end
end
