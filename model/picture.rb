
class Picture < MatchaBase
	extend PictureHelper, PictureHelper::Validator, PictureHelper::DisplayError
	attr_accessor :id, :timestamp, :src, :number_of_report

	def self.cant_be_blank_on_creation
		[:src, :number_of_report]
	end

	def self.labels
		[]
	end

	def self.root_path
		"./assets/pictures/root.png"
	end

	def self.root
		if File.exist?(root_path)
			root =  Picture.where(equality: {src: root_path})
			 if root.any?
				 root[0]
			 else
				 error = create(hash: {src: root_path})
				 exit if !error.any? || !error[0].is_a?(Picture)
				 error[0]
			 end
		else
			false
		end
	end

	def self.create(hash: {})
		unless (error = validator(hash: hash.merge!(number_of_report: 0))).any?
			picture = super(hash: hash)
		else
			error_message(array: error)
		end
	end
end
