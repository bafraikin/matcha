
class Notification < MatchaBase
	extend NotificationHelper, NotificationHelper::Validator
	attr_accessor :type, :id, :timestamp, :seen

	def self.type_possible
		["ROOT", "NEW_MATCH", "NEW_MESSAGE", "SOMEONE_LIKED_YOU"]
	end

	def self.cant_be_blank_on_creation
		[:type, :seen]
	end

	def self.labels 
		[]
	end

	def self.create(type:)
		hash = {type: type, seen: false}
		unless (error = validator(hash: hash)).any?
			super(hash: hash)
		else
			raise "WRONG NOTIFICATION"
		end
	end
end