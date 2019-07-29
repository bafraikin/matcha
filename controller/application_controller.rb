
class ApplicationController < Sinatra::Base
	register Sinatra::Namespace
	set :views, File.expand_path('../../views', __FILE__)



end
