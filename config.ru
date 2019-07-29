require 'bundler/setup'
require 'sinatra'
require 'BCrypt'

files = Dir[ __dir__ + "/controller/*.rb"].each {|file| load file }
models = Dir[__dir__ + "/model/**/*.rb"].each {|file| load file }
controller = files.map{ |file|
	 file[/(?<=\/)[^\/]+(?=\.)/].split('_').map(&:capitalize).join
}.map{|string| Object.const_get(string)}




run Rack::Cascade.new controller
