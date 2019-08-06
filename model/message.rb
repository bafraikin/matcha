
class Message < MatchaBase
	extend MessageHelper, MessageHelper::Validator, MessageHelper::DisplayError
	attr_accessor :id, :timestamp, :body, :id_user

	def self.cant_be_blank_on_creation
		[:body, :id_user]
	end

	def self.labels
		[]
	end

	def create(hash:)
		if !(error = validator(hash: hash)).any?
			super(hash: hash)
		else
			error_message(array: error)
		end
	end
end
