class UserController < ApplicationController

	namespace '/user' do
		get /\/?/ do
			erb :"user.html"
		end

		post "/user_create" do
			a = Array.new
			a << params[:user].delete(:interest1)
			a << params[:user].delete(:interest2)
			User.create(hash: params[:user].merge(interest: a.select{|b|b}))
		end

		get "/chat" do
			unless !request.websocket?
				chat_with
			end
		end
	end

	private	
	def chat_with
		request.websocket do |ws|
			ws.onopen do
				settings.sockets["socket#{settings.sockets.size}"] = ws
			end
			ws.onmessage do |msg|
				EM.next_tick { settings.sockets.each_value{|s| s.send(msg) } }
			end
			ws.onclose do
				warn("websocket closed")
				settings.sockets.delete(settings.sockets.key(ws))
			end
		end
	end
end
