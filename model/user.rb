require './matcha_base.rb'
class User < MatchaBase
	attr_accessor :first_name, :last_name, :sex, :id, :age
end


p User.where(equality: {first_name: "baptiste", last_name: "Fraikin"})
