module UserHelper
	module Validator
		def valid_password?(string)
			if string.nil? || string.size < 8 || string[/\d/].nil? && string[/\w/].nil? || string[/\W/].nil? || string.size > 250
				false
			else
				true
			end
		end

		def valid_popularity_score?(number)
			number.is_a?(Integer)
		end

		def valid_email?(string)
			if string.nil? || string[/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i].nil? || string.length > 80
				false
			else
				true
			end
		end

		def valid_biography?(string)
			return true if string.nil?
			if string.length > 500
				false
			else
				true
			end
		end

		def valid_age?(age)
			if age.nil? || age.to_i < 18 || age.to_i > 98 || age.to_s[/\d+/].size != age.to_s.size
				false
			else
				true
			end
		end

		def valid_first_name?(first_name)
			if first_name.nil? || first_name[/\A\w+\z/].to_s.size < 2 || first_name.length > 20
				false
			else
				true
			end
		end

		def valid_last_name?(last_name)
			if last_name.nil? || last_name[/\A(\w|')+\z/].to_s.size < 2 || last_name.length > 20
				false
			else
				true
			end
		end

		def valid_sex?(sex)
			if sex.nil? || !User.gender_pool.include?(sex)
				false
			else
				true
			end
		end

		def valid_interest?(interest)
			if interest.nil? || !interest.is_a?(Array) || interest.size < 1 || (interest - User.gender_pool).size != 0
				false
			else
				true
			end
		end

		def valid_valuable?(bool)
			if bool == true || bool == false
				true
			else
				false
			end
		end
	end

	module DisplayError
		def error_password
			"A password should at least contain 8 charater, one numeric character, one alphabet letter and one, non alphanumeric letter"
		end

		def error_age
			"Your age should be over 18 or under 98"
		end

		def error_email
			"Your email is not valid"
		end

		def error_sex
			"Your should have a sex and it should be valid"
		end

		def error_biography
			"Way to long, keep it short"
		end

		def error_first_name
			"Your first name should be valid"
		end

		def error_last_name
			"Your last name should be valid"
		end

		def error_interest
			"You should not have interest list empty and filled with good value"
		end

		def error_valuable
			"valuable should be a boolean"
		end
	end
end
