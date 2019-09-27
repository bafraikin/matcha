class Messenger < MatchaBase
	extend MessengerHelper, MessengerHelper::Validator, MessengerHelper::DisplayError
	attr_accessor :id, :match_hash

	def self.cant_be_blank_on_creation
		[:match_hash]
	end

	def self.labels
		[]
	end

	def destroy
		delete_every_node_related(type_of_node: "message")
		super
	end

	def get_messages
		crawl_node_related(type_of_node: "message")
	end

	def create(hash:)
		if !(error = validator(hash: hash)).any?
			super(hash: hash)
		else
			error_message(array: error)
		end
	end

	def new_message(id_user:, body:)
		messages = get_messages
		if messages.size == 0
			add_message(id_user: id_user, body: body)
		else
			messages.last.add_message(id_user: id_user, body: body)
		end
	end

	private

	def add_message(id_user:, body:)
		message = Message.create(hash: {id_user: id_user, body: body})
		if message.any? && message[0].is_a?(Message)
			create_links(id: message[0].id, type: "NEXT_MESSAGE", data: nil)
		end
	end
end
