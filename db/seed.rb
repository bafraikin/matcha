require 'Faker'
require 'BCrypt'
require 'securerandom'
Dir[__dir__ + '/../model/helper/*.rb'].each {|file| require file}
Dir[__dir__ + "/../model/matcha_base.rb"].then{|base| load base[0]}
Dir[__dir__ + '/../model/*.rb'].each {|file| require file}


def random_interest
	interest = ['man', 'woman']
	if rand(1..2) == 2
		interest
	else
		[interest.sample]
	end
end


Hashtag.create
hashtags = Hashtag.all


500.times do
	array = []
	rand(1..4).times { array << hashtags.sample.id}
	array.uniq!
p 	matcheur = User.create(hash: {interest: random_interest, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: "coucou123/", sex: ['man', 'woman'].sample, age: rand(18..35), email: Faker::Internet.unique.email, email_token: SecureRandom.hex})[0]	
	array.each {|id| matcheur.create_links(id: id, type: 'appreciate') }
end
