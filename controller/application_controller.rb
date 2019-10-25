
class ApplicationController < Sinatra::Base
	include MessengerHelper
	include NotifHelper
	register Sinatra::Namespace
	register Sinatra::Flash

	set :views, File.expand_path('../../views', __FILE__)
	set :erb, layout: :'/layout.html'
	set :layout_engine => :erb	
	set :logging, :true
	enable :sessions
	use Rack::Protection
	use Rack::Protection::AuthenticityToken
	set :dump_errors, true
	


	before do
		headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
		headers['Access-Control-Allow-Origin'] = 'https://api.ipify.org/?format=json'
		headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
	  end
	  
	  options '*' do
		headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS,POST'
		headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
	  end

	set :environment, Sprockets::Environment.new
	environment.append_path "assets/stylesheets"
	environment.append_path "assets/javascripts"
	environment.append_path "assets"
	set :sockets, Hash.new

	set :log, Logger.new(STDOUT)

	def h(text)
		    Rack::Utils.escape_html(text)
	end

	def title
		"MATCHA"
	end

	def current_user
		settings.log.info(is_connected?(user: session[:current_user]))
		session[:current_user]
	end

	def user_logged_in?
		!session[:current_user].nil?
	end


	def block_logged_in
		if user_logged_in?
			flash[:error] = "There is nothing to see here"
			redirect "/"
			halt
		end
	end

	def block_access_to_not_valuable_account
		if @user.nil? || !@user.is_valuable?
			flash[:error] = "There is nothing to do here"
			redirect "/"
			halt
		end
	end

	def halt_unsigned
			halt if !user_logged_in?
	end

	def halt_unvalidated
		halt_unsigned
		halt if !current_user.account_validated?
	end

	def halt_unvaluable
		halt_unvalidated
		halt if !current_user.is_valuable?
	end

	def block_unsigned
		if !user_logged_in?
			flash[:error] = "You need to sign in"
			redirect "/"
			halt
		end
	end

	def block_unvalidated
		block_unsigned
		if !current_user.account_validated?
			flash[:error] = "You need to validate your account"
			redirect "/"
			halt
		end
	end

	def block_unvaluable
		block_unvalidated
		if !current_user.is_valuable?
			flash[:error] = "Please add more info on your account before"
			redirect "/"
			halt
		end
	end

	def block_blocked(user:)
		block_unvaluable
		if current_user.is_there_a_block_beetwen_us?(user: user)
			flash[:error] = "Error"
			redirect "/"
			halt
		end
	end

	def halt_blocked(user:)
		halt_unvaluable
		if current_user.is_there_a_block_beetwen_us?(user: user)
			send_notif_to(user: current_user, notif: Notification.new(type: "ERROR"))
			halt
		end
	end

	def is_connected?(user:)
		return false if !user.is_a?(User)
		!settings.sockets[user.key].nil?
	end

	get /\/?/ do
		@users = []
		@hashtags = Hashtag.all
		@hashtag_user = user_logged_in? ? current_user.hashtags.map(&:name) : []
		erb:'matchable.html' 
	end

	get "/assets/*" do
		env["PATH_INFO"].sub!("/assets", "")
		settings.environment.call(env)
	end
end
