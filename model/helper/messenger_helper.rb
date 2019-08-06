module MessengerHelper
	module Validator
		def valid_match_hash?(string)
			if !string.nil? || !string.is_a?(String)
				false
			else
				true
			end
		end
	end
	module DisplayError
		def error_match_hash
			"WTF"
		end
	end
end
