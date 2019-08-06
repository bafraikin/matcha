class Messenger < MatchaBase
	extend MessengerHelper, MessengerHelper::Validator, MessengerHelper::DisplayError
	attr_accessor :id, :match_hash

	def self.cant_be_blank_on_creation
		[:match_hash]
	end

	def self.labels
		[]
	end

	def collapse
		delete_every_node_related(type_of_node: "message")
		self.destroy
	end

	def get_message
		find_every_node_related(type_of_node: "message")
	end

	def create(hash:)
		if !(error = validator(hash: hash)).any?
			super(hash: hash)
		else
			error_message(array: error)
		end
	end

	def get_message
		"MATCH (n:message)-[*]-(m:message) ORDER BY m.timestamp RETURN m"
	end

end