require 'bundler/setup'
require 'sinatra'

configure do
	set  :views, './'
end

get '/' do
	  'Bonjour le monde !'
end
get '/index.html/:id' do
	user.new(params[:id])
end
