
class ApplicationController < Sinatra::Base
	register Sinatra::Namespace
	set :views, File.expand_path('../../views', __FILE__)
	set :sockets, Hash.new
	set :notifications, Hash.new
	enable :sessions
	use Rack::Protection
	use Rack::Protection::AuthenticityToken
end
