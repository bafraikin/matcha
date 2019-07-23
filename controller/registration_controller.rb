class RegistrationController < ApplicationController

def title
	"My Website"
end
	get '/registration' do 
		erb:'coucou.html'
	end

end
