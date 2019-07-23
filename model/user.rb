require './matcha_base.rb'
require 'pry'
class User < MatchaBase
	attr_accessor :first_name, :last_name, :sex, :id, :age, :email, :password, :reset_token, :email_token, :interest

	def interest
		@interest || []
	end

	def self.labels
		[:sex]
	end

	def self.cant_be_blank_on_creation
		[:first_name, :last_name, :password, :sex, :age, :email_token, :email]
	end

end

p User.create(hash: {password: 'coucou', sex: 'man', first_name: 'baptiste', last_name: 'arman', age: 18, email_token: "abc", email: "coucou", interest: ['man', 'women']})

sleep 1

