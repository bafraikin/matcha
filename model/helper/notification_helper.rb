module NotificationHelper
	module Validator
		def valid_type?(string)
			if string.nil? || !string.is_a?(String) || !type_possible.include?(string)
				false
			else
				true
			end
		end

		def valid_seen?(bool)
			if bool.nil? || (!bool.is_a?(TrueClass) && !bool.is_a?(FalseClass))
				false
			else
				true
			end
		end
		module DisplayError
			def error_type
				"The only type accepted is " + type_possible.to_s   
			end
		end
	end
end
