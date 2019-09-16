class UserController < ApplicationController
	include ShowHelper
	include UserControllerHelper
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

		post '/update' do
			block_unsigned
			settings.log.info(params)
			block_unvalidated
			return if params[:id].nil? || params[:content].nil? || !User.attributes.include?(params[:id].to_sym) || !User.updatable.include?(params[:id])
			if (params[:id] == "password")
				return User.error_password if !User.valid_password?(params[:content])
				params[:content] = User.hash_password(password: params[:content])
			end 
			current_user.send(params[:id].to_s + "=", params[:content])
			error = current_user.save
			if error.is_a?(Array)
				session[:current_user] = User.find(id: current_user.id)
				return error.to_json
			else
				return true.to_json
			end
		end

		post '/update_hashtag' do
			block_unsigned
			settings.log.info(params)
			block_unvalidated
			check_good_params_checkbox
			if params[:id] == "hashtag"
				id_hashtag = check_if_valide_hashtag_and_return_id(params[:value])
				return if params[:value].nil? || id_hashtag == false
				if (current_user.is_related_with(id: id_hashtag, type_of_link: "APPRECIATE") == [])
					current_user.create_links(id: id_hashtag, type: "APPRECIATE", data: nil)
				else
					current_user.suppress_his_relation_with(id: id_hashtag)
				end
			else
				halt if !check_if_valide_gender?(params[:value])
				if current_user.interest.include? params[:value]
					current_user.interest.delete(params[:value])
				else
					current_user.interest.push(params[:value])
				end
				error = current_user.save
				if error.is_a?(Array)
					session[:current_user] = User.find(id: current_user.id)
					return error.to_json
				end
			end
			return true.to_json
		end

		get '/show/:id' do
			block_unsigned
			return if params[:id].nil?
			@user = nil
			if current_user.id != params[:id].to_i
				block_unvalidated
				@user = User.find(id: params[:id].to_i) 
			else
				@user = current_user
			end
			if !@user
				redirect "/"
				halt
			else
				@hashtags = Hashtag.all
				@checkboxes =  @user.get_node_related_with(link: "APPRECIATE").map(&:name)
				erb:'show.html'
			end
		end

		post "/add_like" do
			block_unsigned
			settings.log.info(params)
			block_unvalidated
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
