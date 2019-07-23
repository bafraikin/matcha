require './matcha_base.rb'
require 'pry'
class User < MatchaBase
	attr_accessor :first_name, :last_name, :sex, :id, :age
end

a = User.all
p a
