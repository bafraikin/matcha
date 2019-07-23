class CoucouController < ApplicationController

	def title
		'coucou'
	end

	get('/coucou') do 
		erb:'coucou.html'
	end


end
