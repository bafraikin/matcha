class RegistrationController < ApplicationController

	def title
		"registration"
	end

	namespace "/registration" do
		get '/login' do 
			erb:'login.html'
		end

		get '/new'do
			erb:'user.html'
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
			if error.any?
				flash[:error] = error.join('<br/>')
				redirect "/registration/new"
			else
				redirect "/"
			end
		end

	end
end
