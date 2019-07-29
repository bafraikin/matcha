require 'bundler/setup'
require 'sinatra'
require 'BCrypt'
require 'async/websocket/adapters/rack'
require 'set'
require "sinatra/namespace"

files = Dir[ __dir__ + "/controller/*.rb"].each {|file| load file }
models = Dir[__dir__ + "/model/**/*.rb"].each {|file| load file }
controller = files.map{ |file|
	file[/(?<=\/)[^\/]+(?=\.)/].split('_').map(&:capitalize).join
}.map{|string| Object.const_get(string)}


$connections = Set.new

run lambda {|env|
	p env

	Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
		$connections << connection

		while message = connection.read
			$connections.each do |connection|
				connection.write(message)
				connection.flush
			end
		end
	ensure
		$connections.delete(connection)
	end or Rack::Cascade.new controller}
