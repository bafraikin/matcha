
class ApplicationController < Sinatra::Base
	register Sinatra::Namespace
	register Sinatra::Flash

	set :views, File.expand_path('../../views', __FILE__)
	set :erb, layout: :'/layout.html'
	set :sockets, Hash.new
	set :layout_engine => :erb
	enable :sessions
	use Rack::Protection
	use Rack::Protection::AuthenticityToken

	def title
		"MATCHA"
	end

	def current_user
		session[:current_user]
	end

	def user_logged_in?
		!session[:current_user].nil?
	end

end
