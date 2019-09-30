class UserController < ApplicationController
  include ShowHelper
  include UserControllerHelper
  include GeolocalisationHelper
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
      block_unsigned
      block_unvalidated
      @users = current_user.all_matches
      erb:"matches.html"
    end

    get '/open_message' do
      block_unsigned
      block_unvalidated
      id = params[:id].to_i
      halt if (id == 0 && params[:id] != "0") || params[:authenticity_token] != session[:csrf]
      rel = current_user.is_related_with(id: id, type_of_link: "MATCH")
      if rel.any?
        binding.pry
        user = User.find(id: id)
        session[:messenger] = prepare_messenger
        session[:messenger] = add_new_talker(user, rel[0][0].properties[:data])
        return {type: true, name: user.first_name}.to_json
      end
    end

    get	'/likers' do
      block_unsigned
      block_unvalidated
      @users = current_user.all_likers
      erb:"likers.html"
    end

    get '/get_profile_picture/:id' do
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
      to_return  = [:id, :last_name, :first_name, :biography, :age]
      settings.log.info(params)
      block_unsigned
      block_unvalidated
      if valid_params_request?(params)
       @users =  current_user.find_matchable(range: params["range"].to_f / 1000, skip: params["skip"].to_i, limit: params["limit"].to_i)
      end
      @users.map! {|user| user.to_hash.slice(*to_return).merge!({distance: user.distance_with_user(user: current_user)})}.to_json
    end

    get '/destroy' do
      block_unsigned
      current_user.destroy
      session.clear
      redirect "/"
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
          current_user.update_valuable
        end
        name
      else
        "error"
      end
    end

    post '/toggle_profile' do
      block_unsigned
      return "error" if current_user.get_node_related_with(type_of_node: ['picture']).size == 0 || params[:id].nil? || params[:id][/\d+/].to_i.to_s.size != params[:id].to_s.size
      picture = Picture.find(id: params[:id].to_i)
      return "error" if picture.nil?
      current_user.define_photo_as_profile_picture(photo: picture)
    end


    post '/delete_photo' do
      settings.log.info(params)
      block_unsigned
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
        current_user.update_valuable
      end
      pic[0].destroy
      FileUtils.rm("./assets/pictures/" + pic[0].src)
      "true"
    end

    post '/update_hashtag' do
      block_unsigned
      settings.log.info(params)
      block_unvalidated
      check_good_params_checkbox
      session_tmp = session[:current_user].clone
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
          session[:current_user] = session_tmp
          return error.to_json
        end
      end
      return true.to_json
    end

    get '/show/:id' do
      block_unsigned
      block_unvalidated
      return if params[:id].nil?
      @user = nil
      if current_user.id != params[:id].to_i
        @user = User.find(id: params[:id].to_i)
      else
        @user = current_user
      end
      if !@user
        redirect "/"
        halt
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

    post '/geo_update' do
      block_unsigned
      settings.log.info(params)
      save_if_valide_coordinate(params[:latitude], params[:longitude])
    end
  end

  private
  def good_name_picture
    pics = Dir["./assets/pictures/picuser#{current_user.id}*"]
    max_number = pics.max_by{|name| name[/\d+/].to_i}
    good_number = max_number.to_s.match(/#{current_user.id}(\d+)/).to_a[1].to_i + 1
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

