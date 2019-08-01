class CoucouController < ApplicationController


	get('/coucou') do 
		erb:'coucou.html'
	end


end
