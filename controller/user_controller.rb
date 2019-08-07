class UserController < ApplicationController

	def title
		"coucou"
	end

	namespace '/user' do
		get "/socket" do
			if request.websocket? && user_logged_in?
				new_websocket(user: current_user)
			elsif request.websocket?
				request.websocket {}
			end
		end

		post "/add_like" do
				user_to_like = User.find(id: params[:id].to_i)
			if user_logged_in? && !params[:id].to_s.empty? && user_to_like
				current_user.add_like(id: user_to_like.id)
				notif = user_to_like.add_notification(type: "SOMEONE_LIKED_YOU")
			end
		end

		get "/likeable" do
			halt if !user_logged_in?
			@users = current_user.find_matchable
			erb:'matchable.html'
		end
	end

end
