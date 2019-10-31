
module UserControllerHelper
	def check_good_params_checkbox
		halt if params.nil? || params[:id].nil? || params[:value].nil? || !(params[:id] == "hashtag" || params[:id] == "interest")
	end

	def valid_params_request?(params)
		params_that_sould_exist = ["min", "max", "sort", "range", "skip", "ascendant", "limit",  "authenticity_token"]
		possible_sort = ["distance", "age", "interest", "popularity_score"]
		@hashtags.each {|hash| params_that_sould_exist << "hashtag_" + hash.name[1..]}
		return false if params.keys - params_that_sould_exist != []
		return false if !(params["range"].to_i > 100 && params["range"].to_i <= 50000)
		return false if !(params["skip"].to_i > 0 || params["skip"] == "0")
		return false if !(params["limit"].to_i > 0)
		return false if !(params["authenticity_token"] == session["csrf"])
		return false if !(params["ascendant"] == "true" || params["ascendant"] == "false")
		return false if !(params["min"].to_i >= 18 && params["min"].to_i <= 98)
		return false if !(params["max"].to_i >= 18 && params["max"].to_i <= 98)
		return false if !(params["max"].to_i >= params["min"].to_i)
		return false if !(possible_sort.include?(params["sort"]))
		return false if (params["pop_max"].nil?)
		return false if (params["pop_min"].nil?)
		return false if !(params["pop_min"].to_i < params["pop_max"].to_i)
		@hashtags = []
		params_that_sould_exist.each {| param| 
			if param[/hashtag/]
				return false if !["false", "true"].include?(params[param])
				@hashtags <<  "#" + param[/(?<=_).*/] if params[param] == "true"
			end
		}
		true
	end
end
