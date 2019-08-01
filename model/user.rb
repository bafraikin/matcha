class User < MatchaBase
	extend UserHelper, UserHelper::Validator, UserHelper::DisplayError
	include BCrypt
  	BCrypt::Engine.cost = 8
	attr_accessor :first_name, :last_name, :sex, :id, :age, :email, :password, :reset_token, :email_token, :interest, :longitude, :latitude

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

	def add_match(id:, data: nil)
		create_links(id: id, type: "MATCH", data: data)
	end

	def add_like(id:)
		create_links(id: id, type: "LIKE")
	end

	def good_password?(to_test:)
		BCrypt::Password.new(self.password) == to_test
	end

	def range_generator(type:, range:)
		["n.#{type} < n.#{type} + #{range}", 
   "n.#{type} > n.#{type} - #{range}"]
	end

	def self.create(hash: {})
		unless (error = validator(hash: hash)).any?
			binding.pry
			super(hash: hash_password(hash: hash))
		else
			error_message(array: error)
		end
	end

	def save
		unless (error = self.class.validator(hash: self.to_hash)).any?
			super
		else
			self.class.error_message(array: error)
		end
	end

	def find_matchable(*args, range: 0.5, equality: {})
		raise MatchaBase::Error if  self.interest.empty?
		args.map!{|arg| "o." + arg}
		equality.each do |k,v|
			args << v.is_a?(String) ? "o." + k.to_s + " = '" + v.to_s + "' " :  "o." + k.to_s + " = " + v.to_s + " " 
		end
		query = "MATCH (o) WHERE " + self.interest.map{|sex| "o:" + sex}.join(' OR ') + " AND '#{self.sex}' IN o.interest"
		query += " AND " + args.join(" AND ")  if args.size > 0
		query += " RETURN o"
		self.class.query_transform(query: query)
	end


end

