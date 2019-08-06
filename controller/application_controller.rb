
class ApplicationController < Sinatra::Base
	register Sinatra::Namespace
	register Sinatra::Flash

	set :views, File.expand_path('../../views', __FILE__)
	set :erb, layout: :'/layout.html'
	set :layout_engine => :erb	
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

	get /\/?/ do
		erb:"index.html"
	end

	get "/assets/*" do
		env["PATH_INFO"].sub!("/assets", "")
		settings.environment.call(env)
	end

end
