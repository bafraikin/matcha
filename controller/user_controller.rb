class UserController < ApplicationController

	def title
		"coucou"
	end

	namespace '/user' do
		get "/new" do
			erb :"user.html"
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
				redirect "/user"
			else
			redirect "/user"
			end
		end

		get "/chat" do
			if request.websocket? && user_logged_in?
				new_websocket(id: current_user.id)
			elsif request.websocket? 
				request.websocket {}
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
