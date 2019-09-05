require 'Faker'
require 'BCrypt'
require 'securerandom'
Dir[__dir__ + '/../model/helper/*.rb'].each {|file| require file}
Dir[__dir__ + '/../model/*.rb'].each {|file| require file}
file = Dir[__dir__ + '/../assets/pictures/user*.png']
file.map!{|f| f[/(?<=\/)[^\/]*$/]}
def random_interest
	interest = ['man', 'woman']
	if rand(1..2) == 2
		interest
	else
		[interest.sample]
	end
end

500.times do |i|
	user = User.create(hash: {interest: random_interest, biography: Faker::Lorem.paragraph_by_chars ,valuable: true, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, password: "coucou123/", sex: ['man', 'woman'].sample, age: rand(18..35), email: Faker::Internet.unique.email, email_token: SecureRandom.hex});
	pic = Picture.create(hash: {src: file[i]})
	user[0].attach_photo(photo: pic[0])
	user[0].define_photo_as_profile_picture(photo: pic[0])
end
