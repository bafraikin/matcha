
module UserControllerHelper
	def check_good_params_checkbox
		halt if params.nil? || params[:id].nil? || params[:value].nil? || !(params[:id] == "hashtag" || params[:id] == "interest")
	end

  def valid_params_request?(params)
    params_that_sould_exist = ["range", "skip", "limit",  "authenticity_token"]
    halt if params.keys - params_that_sould_exist != []
    halt if !(params["range"].to_i > 100 && params["range"].to_i <= 50000)
    halt if !(params["skip"].to_i > 0 || params["skip"] == "0")
    halt if !(params["limit"].to_i > 0)
    halt if !(params["authenticity_token"] == session["csrf"])
    true
  end
end
