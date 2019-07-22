require 'bundler/setup'
require 'sinatra'
Dir["../controller/*.rb"].each {|file| require file }

configure do
  set  :views, './'
end

get '/' do
  'Bonjour le monde !'
end
get '/index.html/:id' do
  user.new(params[:id])
end
