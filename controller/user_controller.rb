class UserController < ApplicationController
	include ShowHelper
	include UserControllerHelper
	include GeolocalisationHelper
	include NotifHelper
	include MessengerHelper

	def title
		"MATCHA"
	end

	namespace '/user' do
		get '/socket' do
			if request.websocket? && user_logged_in?
				new_websocket(user: current_user)
			elsif request.websocket?
				request.websocket{}
			end
		end

		get '/get_notif' do
			halt_unvaluable
			current_user.set_notif_as_seen.map(&:to_hash).to_json
		end

		get '/viewers' do
			block_unvaluable
			@users = current_user.users_that_looked_my_profile
			erb:"list_users.html"
		end

		post '/report_photo' do
			halt_unvaluable
			request.body.rewind
			@param = JSON.parse request.body.read

		end

		get '/blocked' do
			block_unvaluable
			@users = current_user.blocked_user
			erb:"list_users.html"
		end

		post '/report_user' do
			halt_unvaluable
			request.body.rewind
			@param = JSON.parse request.body.read
			user = User.find(id: @param["user_id"].to_i)
			if user.is_a?(User)
				current_user.toggle_block_user(user: user)
				settings.log.info("user blocked")
			end
		end

		post '/send_message' do
			halt_unvaluable
			request.body.rewind
			@param = JSON.parse request.body.read
			user = User.find(id: @param["user_id"].to_i)
			return false.to_json if !user.is_a?(User)
			if user_message_to(user: user, hash: @param["hash"], body: @param["body"]) && !current_user.is_there_a_block_beetwen_us?(user: user)
				send_socket_message_to(user: user, body: @param["body"], hash_conv: @param["hash"])
				return true.to_json
			else
				session[:messenger] = suppr_talker(talker: user)
				return false.to_json
			end
		end

		post '/update' do
			halt_unvalidated
			settings.log.info(params)
			return if params[:id].nil? || params[:content].nil? || !User.attributes.include?(params[:id].to_sym) || !User.updatable.include?(params[:id])
			session_tmp = session[:current_user].clone
			if (params[:id] == "password")
				return User.error_password if !User.valid_password?(params[:content])
				params[:content] = User.hash_password(password: params[:content])
			end 
			current_user.send(params[:id].to_s + "=", params[:content])
			error = current_user.save
			if error.is_a?(Array)
				session[:current_user] = session_tmp
				return error.to_json
			else
				return true.to_json
			end
		end

		get '/matches' do
			block_unvaluable
			@users = current_user.all_matches_with_hash
			erb:"matches.html"
		end

		get '/matches_hashes' do
			halt_unvaluable
			@users = current_user.all_matches_with_hash
			@users *= 10
			return @users.to_json
		end

		get '/open_message' do
			halt_unvaluable
			id = params[:id].to_i
			halt if (id == 0 && params[:id] != "0") || params[:authenticity_token] != session[:csrf]
			rel = current_user.is_related_with(id: id, type_of_link: "MATCH")
			user = User.find(id: params[:id].to_i)
			if rel.any? && user && !current_user.is_there_a_block_beetwen_us?(user: user)
				hash = rel[0][0].properties[:data]
				messenger = Messenger.where(equality: {match_hash: hash})
				messages = messenger[0].get_messages if messenger.any? && messenger[0].is_a?(Messenger)
				user = User.find(id: id)
				session[:messenger] = prepare_messenger
				session[:messenger] = add_new_talker(user, hash)
				return {first_name: user.first_name, hash_conv: hash, messages: messages.map!(&:to_hash) }.to_json
			end
			false.to_json
		end

		get	'/likers' do
			block_unvaluable
			@users = current_user.all_likers
			erb:"list_users.html"
		end

		get	'/my_likes' do
			block_unvaluable
			@users = current_user.my_likes
			erb:"list_users.html"
		end

		get '/get_profile_picture/:id' do
			halt_unvaluable
			id = params[:id]
			if id && id.to_i > 0 || id == "0"
				id = id.to_i
				user = User.find(id: id)
				img = user.profile_picture
				if img
					return img.src.to_json
				else
					false.to_json
				end
			end
		end

		get	'/get_profiles' do
			halt_unvaluable
			to_return  = [:distance, :id, :last_name, :first_name, :biography, :age]
			@hashtags = Hashtag.all
			settings.log.info(params)
			if valid_params_request?(params)
				@users =  current_user.find_matchable("age >= #{params['min']}", "age <= #{params['max']}", range: params["range"].to_f / 1000, skip: params["skip"].to_i, limit: params["limit"].to_i, asc: JSON.parse(params["ascendant"]), hashtags: @hashtags, sort_by: params["sort"])
			else
				return [].to_json
			end
			@users.map! {|user| user.to_hash.slice(*to_return)}.to_json
		end

		get '/destroy' do
			block_unsigned
			current_user.destroy
			session.clear
			redirect "/"
		end

		post '/add_photo' do
			halt_unvalidated
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
					current_user.update_valuable
				end
				current_user.update_popularity_score(to_add: 10)
				name
			else
				current_user.update_popularity_score(to_add: -50)
				"error"
			end
		end

		post '/toggle_profile' do
			halt_unsigned
			return "error" if current_user.get_node_related_with(type_of_node: ['picture']).size == 0 || params[:id].nil? || params[:id][/\d+/].to_i.to_s.size != params[:id].to_s.size
			picture = Picture.find(id: params[:id].to_i)
			return "error" if picture.nil?
			current_user.define_photo_as_profile_picture(photo: picture)
		end


		post '/delete_photo' do
			settings.log.info(params)
			halt_unsigned
			return "error" if params[:src].nil?
			src = params[:src][/(?<=\/)[^\/]*$/]
			return "error" if !src || src == Picture.root_name
			return "error" if !(pictures = current_user.pictures).map(&:src).include?(src)
			pic = pictures.select{|pic| pic.src == src}
			if pictures.size > 1 && (rel = current_user.is_related_with(id: pic[0].id))
				if rel.any?
					rel = rel[0][0]
				else
					return "error"
				end
				if rel.type.to_s == "PROFILE_PICTURE"
					current_user.define_photo_as_profile_picture(photo: pictures.select{|pic| pic.src != src}[0])
				end
			else
				current_user.root_photo_is_now_profile_picture
				current_user.update_popularity_score(to_add: -15)
				current_user.update_valuable
			end
			pic[0].destroy
			FileUtils.rm("./assets/pictures/" + pic[0].src)
			current_user.update_popularity_score(to_add: -10)
			true.to_json
		end

		post '/update_hashtag' do
			settings.log.info(params)
			halt_unvalidated
			check_good_params_checkbox
			session_tmp = session[:current_user].clone
			if params[:id] == "hashtag"
				id_hashtag = check_if_valide_hashtag_and_return_id(params[:value])
				return if params[:value].nil? || id_hashtag == false
				if (current_user.is_related_with(id: id_hashtag, type_of_link: "APPRECIATE") == [])
					current_user.create_links(id: id_hashtag, type: "APPRECIATE", data: nil)
					current_user.update_popularity_score(to_add: 2)
				else
					current_user.suppress_his_relation_with(id: id_hashtag)
					current_user.update_popularity_score(to_add: 2)
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
					session[:current_user] = session_tmp
					return error.to_json
				end
			end
			return true.to_json
		end

		get '/show/:id' do
			headers "Cache-Control" => "no-cache"
			block_unvalidated
			return if params[:id].nil?
			block_unvaluable if params[:id].to_i != current_user.id
			@user = User.find(id: params[:id].to_i)
			block_blocked(user: @user) if params[:id].to_i != current_user.id && @user
			if !@user
				redirect "/"
				halt
			elsif current_user.id != @user.id
				@like = @user.is_related_with(id: current_user.id, type_of_link: "LIKE|:MATCH", orientation: true).any?
				@user.update_popularity_score(to_add: 1)
				send_notif_view_to(user: @user)
				current_user.has_view(user: @user)
			else
				@user = current_user
			end
			block_access_to_not_valuable_account if params[:id].to_i != current_user.id
			@profile_picture = @user.profile_picture
			@pictures = @user.get_node_related_with(link: "BELONGS_TO", type_of_node: ['picture'])
			@pictures.select!{|pic| pic.id != @profile_picture.id}
			@hashtags = Hashtag.all
			@checkboxes =  @user.get_node_related_with(link: "APPRECIATE").map(&:name)
			@user.distance = current_user.distance_with_user(user: @user)
			erb:'show.html'
		end

		post "/toggle_like" do
			settings.log.info(params)
			halt_unvaluable
			user_to_like = User.find(id: params[:id].to_i)
			if !params[:id].to_s.empty? && user_to_like
				halt_blocked(user: user_to_like)
				notif = nil
				likes = current_user.is_related_with(id: user_to_like.id, type_of_link: "LIKE | :MATCH")
				if likes.empty?
					current_user.add_like(id: user_to_like.id)
					user_to_like.update_popularity_score(to_add: 10)
					send_notif_like(user_to_receive: user_to_like)
				elsif (my_like = likes.select {|like| like[0].start_node_id == current_user.id}).any?
					if likes[0][0].type.to_s == "MATCH"
						send_notif_unmatch(first_user: current_user, second_user: user_to_like)
						current_user.delete_match_with(id: user_to_like.id)
						user_to_like.update_popularity_score(to_add: -25)
					else
						current_user.destroy_relation(id: my_like[0][0].id)
						user_to_like.update_popularity_score(to_add: -10)
					end
				else
					current_user.add_match(id: user_to_like.id)
					send_notif_match(first_user: current_user, second_user: user_to_like)
					settings.log.info("NEW MATCH")
				end
			end
		end

		post '/geo_update' do
			halt_unsigned
			settings.log.info(params)
			save_if_valide_coordinate(params[:latitude], params[:longitude])
		end
	end

	private
	def good_name_picture
		pics = Dir["./assets/pictures/picuser#{current_user.id}*"]
		max_number = pics.max_by{|name| name[/\d+/].to_i}
		good_number = max_number.to_s.match(/#{current_user.id}(\d+)/).to_a[1].to_i + 1
		"picuser#{current_user.id}#{good_number}"
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
