
class ApplicationController < Sinatra::Base
	register Sinatra::Namespace
	set :views, File.expand_path('../../views', __FILE__)
	set :erb, layout: :'/layout.html'
	set :sockets, Hash.new
	set :notifications, Hash.new
	set :layout_engine => :erb
	enable :sessions
	use Rack::Protection
	use Rack::Protection::AuthenticityToken

	def title
		"MATCHA"
	end
end
