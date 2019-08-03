class UserController < ApplicationController

	def title
		"coucou"
	end

	namespace '/user' do

		get "/socket" do
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
