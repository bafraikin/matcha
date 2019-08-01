class UserController < ApplicationController

	def title
		"coucou"
	end

	namespace '/user' do
		get /\/?/ do
			erb :"user.html"
		end

		post "/user_create" do
			array = Array.new
			1.upto(2) do |i|
				symbol = ("interest" + i.to_s).to_sym
				array << params[:user].delete(symbol) if params[:user].key?(symbol)
			end
			User.create(hash: params[:user].merge(interest: array))
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
