
class Message < MatchaBase
	extend MessageHelper, MessageHelper::Validator, MessageHelper::DisplayError
	attr_accessor :id, :timestamp, :src, :number_of_report

	def self.cant_be_blank_on_creation
		[:src, :number_of_report]
	end

	def self.labels
		[]
	end

	def create(hash: )
	end

end
