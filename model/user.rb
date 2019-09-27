class User < MatchaBase
	extend UserHelper, UserHelper::Validator, UserHelper::DisplayError
	include BCrypt
	BCrypt::Engine.cost = 8
	attr_accessor :first_name, :biography, :last_name, :sex, :id, :age, :email, :password, :reset_token, :email_token, :interest, :longitude, :latitude, :timestamp, :valuable

	def interest
		@interest || []
	end

	def self.labels
		[]
	end

	def destroy
		pictures.map(&:destroy)
		super
	end

	def all_matches
		self.get_node_related_with(link: "MATCH", type_of_node: ["user"]).uniq {|user| user.email}
	end

	def all_likers
		self.get_node_related_with(link: "LIKE", type_of_node: ['user'], to_me: true)
	end

	def self.cant_be_blank_on_creation
		[:interest, :first_name, :last_name, :password, :sex, :age, :email_token, :email, :valuable]
	end

	def cant_be_empty_for_valuable_account
		[:interest, :first_name, :sex, :age, :pictures, :biography]
	end

	def is_valuable?
		self.cant_be_empty_for_valuable_account.select do |method|
			self.send(method).then do|result|
				if result.is_a?(Array) || result.is_a?(String)
					result.empty?
				elsif result.is_a?(Integer)
					result < 18
				else
					result.nil?
				end
			end
		end.empty?
	end

	def update_valuable
		self.valuable = self.is_valuable?
		self.save
	end

	def self.gender_pool
		['man', 'woman', 'chicken'] 
	end

	def self.updatable
		['age', 'password', 'biography', 'first_name', 'last_name', 'email', 'sex']
	end

	def self.hash_password(password:)
		BCrypt::Password.create(password)
	end


	def full_name
		self.first_name + " " + self.last_name
	end

	def account_validated?
		self.email_token.nil?
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
		if messenger = Messenger.where(equality: {data: rel.data}).first
			messenger.collapse
		end
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
		root_photo_is_now_profile_picture
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

	def attach_photo(photo:)
		if photo.is_a?(Picture)
			create_links(id: photo.id, type: "BELONGS_TO")
			true
		else
			false
		end
	end

	def profile_picture
		self.get_node_related_with(link: "PROFILE_PICTURE", type_of_node: ["picture"])[0]
	end

	def pictures
		pictures = self.get_node_related_with(link: "BELONGS_TO", type_of_node: ["picture"])
	end

	def define_photo_as_profile_picture(photo:)
		if photo.is_a?(Picture)
			rel = self.is_related_with(id: photo.id, type_of_link: "BELONGS_TO")
			if rel.any? 
				rel = rel[0][0] 
			else
				return false
			end
			last_profile_picture = self.get_node_related_with(link: "PROFILE_PICTURE", type_of_node: ["picture"])
			if last_profile_picture.any?
				rel_last_picture = self.is_related_with(id: last_profile_picture[0].id, type_of_link: "PROFILE_PICTURE")
				self.destroy_relation(id: rel_last_picture[0][0].id)
				self.create_links(id: photo.id, type: "PROFILE_PICTURE")
			else
				return false
			end
			update_valuable
			true
		else
			false
		end
	end

	def root_photo_is_now_profile_picture
		picture_default = Picture.root
		create_links(id: picture_default.id, type: "PROFILE_PICTURE")
		update_valuable
	end

	def self.create(hash: {})
		hash[:valuable] = false
		unless (error = validator(hash: hash)).any?
			user = super(hash: hash.merge!(password: hash_password(password: hash[:password])))
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
		self.valuable = self.is_valuable?
		unless (error = self.class.validator(hash: self.to_hash)).any?
			super
		else
			self.class.error_message(array: error)
		end
	end

	def find_matchable(*args, range: 0.5, equality: {}, limit: 7)
		raise MatchaBase::Error if  self.interest.empty?
		args.map!{|arg| "o." + arg}
		equality.each do |k,v|
			args << v.is_a?(String) ? "o." + k.to_s + " = '" + v.to_s + "' " :  "o." + k.to_s + " = " + v.to_s + " " 
		end
		interest = self.interest.map{|sex| "other.sex = '#{sex}'"}.join(' OR ')
		interest = "(#{interest})" if self.interest.size > 1
		query = "MATCH (self:user {email: '#{self.email}'})
		OPTIONAL MATCH (self)-[:LIKE | :MATCH]->(other:user) 
		WITH  COLLECT(DISTINCT other) as to_exclude, self"
		query += " MATCH (other:user)"
		query+= " WHERE " + interest + " AND '#{self.sex}' IN other.interest AND NOT self = other AND NOT other IN to_exclude AND other.valuable = true"
		query += " AND " + args.join(" AND ")  if args.size > 0
		query += " RETURN other LIMIT {limit}"
		self.class.query_transform(query: query, hash: {limit: limit})
	end
end

