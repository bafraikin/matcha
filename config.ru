require 'bundler/setup'
require 'sinatra'
require 'BCrypt'
require 'set'
require "sinatra/namespace"
require 'pony'
require 'sinatra-websocket' 
require 'sinatra/flash' 
require 'rack/protection'
require 'sprockets'
require 'erubis'


models = Dir[__dir__ + "/model/**/*.rb"].each {|file| load file }
helper_controller = Dir[ __dir__ + "/controller/helper/*.rb"].each {|file| load file }
files = Dir[ __dir__ + "/controller/*.rb"].each {|file| load file }

controller = files.map{ |file|
	file[/(?<=\/)[^\/]+(?=\.)/].split('_').map(&:capitalize).join
}.map{|string| Object.const_get(string)}

run Rack::Cascade.new controller
