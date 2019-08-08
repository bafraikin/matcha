class User < MatchaBase
	extend UserHelper, UserHelper::Validator, UserHelper::DisplayError
	include BCrypt
	BCrypt::Engine.cost = 8
	attr_accessor :first_name, :last_name, :sex, :id, :age, :email, :password, :reset_token, :email_token, :interest, :longitude, :latitude, :timestamp

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

	def add_match(id:)
		data = SecureRandom.hex
		rel = self.is_related_with(id: id, type_of_link: "LIKE")
		rel.any? ? rel = rel[0][0] : return
		create_links(id: id, type: "MATCH", data: data)
		replace_relation(id: rel.id, new_type: "MATCH", new_data: data)
		Messenger.create(hash: {match_hash: data})
	end

	def delete_match_with(id:)
		rel = self.is_related_with(id: id, type_of_link: "MATCH")
		rel.any? ? rel = rel[0][0] : return
		suppress_his_relation_with(id: id)
		replace_relation(id: rel.id, new_type: "LIKE", new_data: nil)
		Messenger.where(equality: {data: rel.data}).first.collapse
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

	def build_attachement
		notif  = Notification.create(type: "ROOT")
		create_links(id: notif[0].id, type: "NOTIFICATION_POOL")
	end

	def add_notification(type:)
		notif_root = get_node_related_with(link: "NOTIFICATION_POOL", type_of_node: ["notification"])
		notif_to_add = Notification.create(type: type)
		if notif_to_add[0].is_a?(Notification)
			notif_root[0].create_links(id: notif_to_add[0].id, type: "NOTIF")
			notif_to_add[0]
		else
			notif_to_add
		end
	end

	def self.create(hash: {})
		unless (error = validator(hash: hash)).any?
			user = super(hash: hash_password(hash: hash))
			user[0].build_attachement if user.any?
			user
		else
			error_message(array: error)
		end
	end

	def key
		"user#{self.id}".to_sym
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
		interest = self.interest.map{|sex| "other:" + sex}.join(' OR ')
		interest = "(#{interest})" if self.interest.size > 1
		query = "MATCH (self:user {email: '#{self.email}'})
		OPTIONAL MATCH (self)-[:LIKE | :MATCH]->(other:user) 
		WITH  COLLECT(DISTINCT other) as to_exclude, self"
		query += " MATCH (other:user)"
		query+= " WHERE " + interest + " AND '#{self.sex}' IN other.interest AND NOT self = other AND NOT other IN to_exclude"
		query += " AND " + args.join(" AND ")  if args.size > 0
		query += " RETURN other"
		self.class.query_transform(query: query)
	end
end

