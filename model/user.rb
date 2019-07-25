class User < MatchaBase
	extend UserHelper, UserHelper::Validator, UserHelper::DisplayError
	include
	attr_accessor :first_name, :last_name, :sex, :id, :age, :email, :password, :reset_token, :email_token, :interest

	def interest
		@interest || []
	end

	def self.labels
		[:sex]
	end

	def self.cant_be_blank_on_creation
		[:interest, :first_name, :last_name, :password, :sex, :age, :email_token, :email]
	end

	def self.hash_password(hash:)
		hash[:password] = BCrypt::Password.create(hash[:password])
		hash
	end

	def self.good_password?(to_test:, hash:)
		BCrypt::Password.new(hash) == to_test
	end


	def self.create(hash: {})
		unless (error = validator(hash: hash)).any?
			super(hash: hash)
		else
			error_message(array: error)
		end
	end

	def find_matchable(range: 0.5)
		raise MatchaBase::Error if  self.interest.empty?
		query = "MATCH (o) WHERE " + self.interest.map{|sex| "o:" + sex}.join(' OR ') + " AND '#{self.sex}' IN o.interest RETURN o"
		self.class.query_transform(query: query)
	end

end

