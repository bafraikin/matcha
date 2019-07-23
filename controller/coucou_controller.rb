class CoucouController < ApplicationController

	def title
		'coucou'
	end

	get('/coucou') do 
		binding.pry
		erb:'coucou.html'
	end


end
