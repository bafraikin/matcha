require 'bundler/setup'
require 'sinatra'

files = Dir["./controller/*.rb"].each {|file| load file }
controller = files.map{ |file|
	 file[/(?<=\/)[^\/]+(?=\.)/].split('_').map(&:capitalize).join
}.map{|string| Object.const_get(string)}


run Rack::Cascade.new controller
