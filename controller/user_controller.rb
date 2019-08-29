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

		post '/update' do
			settings.log.info(params)
			block_unsigned
			return if params[:id].nil? || params[:content].nil? || !User.attributes.include?(params[:id].to_sym)
			current_user.send(params[:id].to_s + "=", params[:content])
			error = current_user.save
			if error.is_a?(Array)
				return error.to_json
			else
				return true.to_json
			end
		end

		post '/add_photo' do
			block_unsigned
			return "error 5 picture is a max" if current_user.get_node_related_with( type_of_node: ["picture"]).size >= 5
			return "error" if !params[:file]
			return "error Picture must be lighter" if params[:file].size > 500000
			type = params[:file].slice(0,50)[/jpeg|png|jpg/]
			file = Base64.decode64(params[:file][(params[:file].index(",")+1)..])
			return "error wrong picture type" if !type
			if name = create_file(data: file, type: type)
				pic = Picture.create(hash: {src: name})
				return "error" if !pic.any? || !pic[0].is_a?(Picture)
				current_user.attach_photo(photo: pic[0])
				if current_user.profile_picture.src == Picture.root_name
					current_user.define_photo_as_profile_picture(photo: pic[0])
				end
				name
			else
				"error"
			end
		end

		post '/delete_photo' do
			block_unsigned
			return "error" if params[:src]
			return "error" if !(pic = Picture.where(equality: {src: params[:src]})).any?
			return "error" if current_user.pictures.map(&:src).include?(params[:src])
			binding.pry
		end

		get '/show/:id' do
			return if params[:id].nil?
			block_unsigned
			block_unvalidated if (current_user.id != params[:id].to_i)
			@user = User.find(id: params[:id].to_i)
			@profile_picture = @user.profile_picture
			@pictures = @user.get_node_related_with(link: "BELONGS_TO", type_of_node: ['picture'])
			if !@user
				redirect "/"
				halt
			else
				erb:'show.html'
			end
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

	private
	def good_name_picture
		pics = Dir["./assets/pictures/userpic#{current_user.id}*"]
		max_number = pics.max_by{|name| name[/\d+/].to_i}
		good_number = max_number.to_s[/\d+/].to_i + 1
		"userpic#{current_user.id}#{good_number}"
	end

	def create_file(data:, type:)
		name = good_name_picture + ".#{type}"
		file = File.open("./assets/pictures/" + name, "w+")
		if file
			size = file.write(data)
			if size = data.size
				name
			else
				false
			end
		else
			false
		end
	end
end
