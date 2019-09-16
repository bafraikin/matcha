
module UserControllerHelper
	def check_good_params_checkbox
		halt if params.nil? || params[:id].nil? || params[:value].nil? || !(params[:id] == "hashtag" || params[:id] == "interest")
	end
end
