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

    get '/show/:id' do
      block_unsigned_and_unvalidated
      @user = User.find(id: params[:id])
      @user = @user[0] if user.any?
    end

		post "/add_like" do
			settings.log.info(params)
			user_to_like = User.find(id: params[:id].to_i)
			if user_logged_in? && !params[:id].to_s.empty? && user_to_like
				notif = nil
				like = current_user.is_related_with(id: user_to_like.id, type_of_link: "LIKE")
				if like.empty?
					current_user.add_like(id: user_to_like.id)
					notif = user_to_like.add_notification(type: "SOMEONE_LIKED_YOU")
					send_notif_to(user: user_to_like, notif: notif)
				elsif like[0][0].start_node_id == current_user.id
					settings.log.info("LIKE DEUX FOIS")
					return
				else
					current_user.add_match(id: user_to_like.id)
					notif = user_to_like.add_notification(type: "NEW_MATCH")
					notif_current = current_user.add_notification(type: "NEW_MATCH")
					send_notif_to(user: user_to_like, notif: notif, from: current_user)
					send_notif_to(user: current_user, notif: notif_current, from: user_to_like)
					settings.log.info("NEW MATCH")
				end
			end
		end
	end

end
