
class ApplicationController < Sinatra::Base
	register Sinatra::Namespace
	register Sinatra::Flash

	set :views, File.expand_path('../../views', __FILE__)
	set :erb, layout: :'/layout.html'
	set :layout_engine => :erb	
	set :logging, :true
	enable :sessions
	use Rack::Protection
	use Rack::Protection::AuthenticityToken

	set :environment, Sprockets::Environment.new
	environment.append_path "assets/stylesheets"
	environment.append_path "assets/javascripts"
	environment.append_path "assets"
	set :sockets, Hash.new

	set :log, Logger.new(STDOUT)

	def title
		"MATCHA"
	end

	def current_user
		session[:current_user]
	end

	def user_logged_in?
		!session[:current_user].nil?
	end

	def is_connected?(user:)
		return false if !user.is_a?(User)
		!settings.sockets[user.key].nil?
	end

	def send_notif_to(user:, notif:, from: nil)
		return if !user.is_a?(User) && !is_connected?(user: user)
		settings.sockets[user.key].send(notif.to_json)
	end

	get /\/?/ do
		@users = []
		if user_logged_in?
		@users = current_user.find_matchable
		end
		erb:'matchable.html'
	end

	get "/assets/*" do
		env["PATH_INFO"].sub!("/assets", "")
		settings.environment.call(env)
	end

	private	
	def new_websocket(user:)
		key = user.key
		request.websocket do |ws|
			ws.onopen do
				settings.sockets[key] = ws
			end
			ws.onmessage do |msg|
				p msg
				EM.next_tick { send_notif_to(user: user, notif: msg)}
			end
			ws.onclose do
				warn("websocket closed")
				settings.sockets.delete(key)
			end
		end
	end
end
