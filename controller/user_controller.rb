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

		post "/add_like" do
			if user_logged_in? && !params[:id].to_s.empty? 
				current_user.add_like(id: params[:id].to_i)
			end
		end

		get "/likeable" do
			halt if !user_logged_in?
			@users = current_user.find_matchable
			erb:'matchable.html'
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
