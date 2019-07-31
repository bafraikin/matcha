class UserController < ApplicationController

	namespace '/user' do
		get /\/?/ do
			erb :"user.html"
		end

		get "/chat" do
			if !request.websocket?
				erb :"user.html"
			else
				request.websocket do |ws|
					ws.onopen do
						ws.send("Hello World!")
						settings.sockets << ws
					end
					ws.onmessage do |msg|
						EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
					end
					ws.onclose do
						warn("websocket closed")
						settings.sockets.delete(ws)
					end
				end
			end
		end
	end
end
