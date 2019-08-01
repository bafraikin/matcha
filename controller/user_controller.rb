class UserController < ApplicationController

	def title
		"coucou"
	end

	namespace '/user' do
		get /\/?/ do
			erb :"user.html"
		end

		post "/user_create" do
			hash = params[:user]
			hash[:age]= hash[:age].to_i
			array = Array.new
			1.upto(2) do |i|
				symbol = ("interest" + i.to_s).to_sym
				array << hash.delete(symbol) if hash.key?(symbol)
			end
			hash.delete(:confirm_password)
			hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
			User.create(hash: hash.merge({interest: array, email_token: SecureRandom.hex}))
			redirect "/user"
		end

		get "/chat" do
			if request.websocket? && user_logged_in?
				new_websocket(id: current_user.id)
			end
		end
	end

	private	
	def new_websocket(id:)
		key = "user#{id}".to_sym
		request.websocket do |ws|
			ws.onopen do
				settings.sockets[key] = ws
			end
			ws.onmessage do |msg|
				EM.next_tick { settings.sockets.each_value{|s| s.send(msg) } }
			end
			ws.onclose do
				warn("websocket closed")
				settings.sockets.delete(key)
			end
		end
	end
end
