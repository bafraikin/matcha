class User < MatchaBase
	extend UserHelper, UserHelper::Validator, UserHelper::DisplayError
	include BCrypt
	BCrypt::Engine.cost = 8
	attr_accessor :first_name, :popularity_score, :biography, :last_name, :sex, :id, :age, :email, :password, :reset_token, :email_token, :interest, :longitude, :latitude, :timestamp, :valuable, :distance

	def interest
		@interest || []
	end

	def self.labels
		[]
	end

	def messengers
		query=<<QUERY 
		MATCH (n:user {email: '#{self.email}'})-[r:MATCH]-(:user)
		OPTIONAL MATCH(mess:messenger {match_hash: r.data}) RETURN mess
QUERY
		self.class.query_transform(query: query)
	end

	def self.default_value
		{popularity_score: 20, valuable: false}
	end

	def self.cant_be_blank_on_creation
		[:interest, :first_name, :last_name, :password, :sex, :age, :email_token, :email, :valuable]
	end

	def cant_be_empty_for_valuable_account
		[:interest, :first_name, :sex, :age, :pictures, :biography]
	end

	def destroy
		pictures.map(&:destroy)
		super
	end

	def is_there_a_block_beetwen_us?(user:)
		block = self.is_related_with(id: user.id, type_of_link: "BLOCK")
		block.any?
	end

	def has_view(user:)
		create_links(id: user.id, type: "HAS_VIEW", data: nil)
	end

	def users_that_looked_my_profile
		self.get_node_related_with(link: "HAS_VIEW", type_of_node: ["user"], to_me: true)
	end

	def blocked_user
		self.get_node_related_with(link: "BLOCK", type_of_node: ["user"], to_them: true)
	end

	def hashtags
		self.get_node_related_with(link: "APPRECIATE", type_of_node: ["hashtag"], to_them: true)
	end

	def toggle_block_user(user:)
		blocked = self.blocked_user
		delete_match_with(id: user.id) if is_match_with(user_id: user.id) != false
		unless blocked.map(&:id).include?(user.id)
			self.suppress_his_relation_with(id: user.id)
			self.create_links(id: user.id, type: "BLOCK", data: nil)
			user.update_popularity_score(to_add: -70)
		else
			self.suppress_his_relation_with(id: user.id)
			user.update_popularity_score(to_add: 70)
		end
	end

	def get_notifs
		query =<<QUERY
	  MATCH (n:user {email: "#{self.email}"}) WITH n
MATCH (n)--(m:notification) WITH m
MATCH (m)--(d:notification) WHERE d.seen = false RETURN d ORDER BY d.timestamp
QUERY
		self.class.query_transform(query: query)
	end

	def set_notif_as_seen
		query =<<QUERY
	  MATCH (n:user {email: "fraikin.baptiste@gmail.com"}) WITH n
MATCH (n)--(m:notification) WITH m
MATCH (m)--(d:notification) WHERE d.seen = false SET d.seen = true RETURN d ORDER BY d.timestamp
QUERY
		self.class.query_transform(query: query)
	end

	def all_matches
		self.get_node_related_with(link: "MATCH", type_of_node: ["user"]).uniq {|user| user.email}
	end


	def all_likers
		self.get_node_related_with(link: "LIKE", type_of_node: ['user'], to_me: true)
	end

	def my_likes
		self.get_node_related_with(link: "LIKE", type_of_node: ['user'], to_them: true)
	end


	def is_match_with(user_id:)
		match = self.is_related_with(id: user_id, type_of_link: "MATCH")
		if match.any?
			return match[0][0]
		else
			return false
		end
	end

	def update_popularity_score(to_add:)
		self.popularity_score += to_add
		self.save
	end

	def filled_in_interest?
		hash = Hashtag.all.map(&:to_hash)
		hash.size > (hash - hashtags.map(&:to_hash)).size
	end

	def is_valuable?
		bool = self.cant_be_empty_for_valuable_account.select do |method|
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
		bool && filled_in_interest?
	end

	def update_valuable
		self.valuable = self.is_valuable?
		self.save
	end

	def self.gender_pool
		# https://en.wikipedia.org/wiki/Non-binary_gender
		['Man', 'Woman', 'Genderfluid', 'Agender', 'Demigender'] 
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
		rel = self.is_related_with(id: id, type_of_link: "MATCH", orientation: true, to_me: true)
		rel.any? ? rel = rel[0][0] : return
		suppress_his_relation_with(id: id)
		replace_relation(id: rel.id, new_type: "LIKE", new_data: nil)
		if messenger = Messenger.where(equality: {match_hash: rel.properties[:data]}).first
			messenger.destroy
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
		hash.merge!(default_value)
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

	def distance_with_user(user:)
		radius = 6371
		phi_1 = latitude * Math::PI / 180
		phi_2 = user.latitude * Math::PI / 180
		delta_phi = (user.latitude - latitude) * Math::PI / 180
		delta_lambda = (user.longitude - longitude ) * Math::PI / 180

		var_1 = Math.sin(delta_phi / 2) * Math.sin(delta_phi / 2) + Math.cos(phi_1) * Math.cos(phi_2) * Math.sin(delta_lambda / 2) * Math.sin(delta_lambda / 2)
		var_2 = 2 * Math.atan2(Math.sqrt(var_1), Math.sqrt(1 - var_1))
		distance = (radius * var_2).round(1)
	end

	def distance_between_user_formula
		"2 * 6371 * asin(sqrt(haversin(radians(lat - other.latitude))+ cos(radians(lat))* cos(radians(other.latitude))* haversin(radians(lon - other.longitude))))"
	end

	def find_matchable(*args, range: 0.5, equality: {}, limit: 7, skip: 0, asc: true, hashtags:, sort_by:)
		raise MatchaBase::Error if  self.interest.empty?
		asc = asc ? "" : "DESC"
		args.map!{|arg| "other." + arg}
		equality.each do |k,v|
			args << v.is_a?(String) ? "other." + k.to_s + " = '" + v.to_s + "' " :  "other." + k.to_s + " = " + v.to_s + " " 
		end
		interest = self.interest.map{|sex| "other.sex = '#{sex}'"}.join(' OR ')
		interest = "(#{interest})" if self.interest.size > 1
		query = "MATCH (self:user {email: '#{self.email}'})
	OPTIONAL MATCH (self)-[:LIKE | :MATCH |:BLOCK]->(other:user) 
	OPTIONAL MATCH (self)<-[:BLOCK]-(exclude_either:user)
	WITH  COLLECT(DISTINCT other) as to_exclude, COLLECT(DISTINCT exclude_either) as other_to_exclude, self, #{self.latitude} AS lat, #{self.longitude} AS lon"
		query += " MATCH (other:user)"
		query += " WHERE " + interest + " AND '#{self.sex}' IN other.interest AND NOT self = other AND NOT other IN to_exclude AND NOT other IN other_to_exclude AND other.valuable = true"
		query += " AND " + args.join(" AND ")  if args.size > 0
		query += " AND #{distance_between_user_formula} < {range}"
		query += "OPTIONAL MATCH (other)-[r:APPRECIATE]->(tag:hashtag) WHERE tag.name IN #{hashtags}"
		query += " WITH count(r) AS interest, other, #{distance_between_user_formula} AS distance, other.popularity_score AS popularity_score, other.age AS age"
		query += " RETURN other{.*, number: interest, distance:distance, id: ID(other), label: labels(other)[0] } ORDER BY #{sort_by} #{asc} SKIP {skip} LIMIT {limit}"
		self.class.query_transform(query: query, hash: {limit: limit, skip: skip, range: range})
	end

	def all_matches_with_hash
		query =<<QUERY 
	MATCH (n:user)-[r:MATCH]->(m:user) WHERE ID(n) = #{self.id} WITH r,m
	MATCH (m)-[:PROFILE_PICTURE]-(k) RETURN {hash_conv: r.data, biography: m.biography ,first_name: m.first_name, user_id: ID(m), src: k.src}
QUERY
		self.class.perform_request(query: query).rows.flatten
	end
end

