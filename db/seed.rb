require 'Faker'
require 'BCrypt'
require 'securerandom'
Dir[__dir__ + '/../model/helper/*.rb'].each {|file| require file}
Dir[__dir__ + "/../model/matcha_base.rb"].then{|base| load base[0]}
Dir[__dir__ + '/../model/*.rb'].each {|file| require file}
file = Dir[__dir__ + '/../assets/pictures/user*.png']
file.map!{|f| f[/(?<=\/)[^\/]*$/]}
def random_interest
	interest = User.gender_pool
	if rand(1..2) == 2
		interest
	else
		[interest.sample]
	end
end

Hashtag.create
hashtags = Hashtag.all


500.times do |i|
	array = []
	rand(1..4).times { array << hashtags.sample.id}
	array.uniq!

	p 	matcheur = User.create(hash: {interest: random_interest, biography: Faker::Quotes::Shakespeare.romeo_and_juliet_quote ,first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: "coucou123/", sex: User.gender_pool.sample, age: rand(18..35), email: Faker::Internet.unique.email, email_token: nil, latitude: rand(48.0..48.9), longitude: rand(2.0..3.9)})[0]
	array.each {|id| matcheur.create_links(id: id, type: 'appreciate') }
	pic = Picture.create(hash: {src: file[i]})
	matcheur.attach_photo(photo: pic[0])
	matcheur.define_photo_as_profile_picture(photo: pic[0])
	matcheur.update_valuable 
end
