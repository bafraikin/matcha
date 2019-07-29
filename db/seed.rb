require 'Faker'
require 'BCrypt'
require 'securerandom'
Dir[__dir__ + '/../model/helper/*.rb'].each {|file| require file}
Dir[__dir__ + '/../model/*.rb'].each {|file| require file}


def random_interest
	interest = ['man', 'women']
	if rand(1..2) == 2
		interest
	else
		[interest.sample]
	end
end

500.times do
p 	User.create(hash: {interest: random_interest, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: "coucou123/", sex: ['man', 'women'].sample, age: rand(18..35), email: Faker::Internet.unique.email, email_token: SecureRandom.hex});
end
