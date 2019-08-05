require 'bundler/setup'
require "neo4j-core"
require 'neo4j/core/cypher_session/adaptors/http'
require 'pry'
Dir[__dir__ + "/../lib/*.rb"].each {|file| require file }

class MatchaBase 
	extend ValidatorHelper
	@@adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://localhost:7474')
	@@session = Neo4j::Core::CypherSession.new(@@adaptor) 
	class Error < StandardError; end

	def self.attr_accessor(*vars)
		@attributes ||= []
		@attributes.concat vars
		super(*vars)
	end

	def to_hash
		self.attributes.reduce({}) {| hash, value| hash[value] = self.send(value.to_s) ; hash}
	end

	def replace_relation(id:, new_type:, new_data: nil)
		query = "MATCH (n)-[r]->(m)
		WHERE ID(r) = #{id}
		WITH n, r, m
		CREATE (n)-[:#{new_type} {timestamp: timestamp(), data: '#{new_data}'}]->(m)
		WITH r
		DELETE r"
		self.class.perform_request(query: query, hash: {})
	end

	def self.attributes
		@attributes
	end

	def attributes
		self.class.attributes
	end

	def self.class_name
		self.name.downcase
	end

	def self.all(*args)
		query = ""
		if args.size === 0
			query = "MATCH (n:#{class_name}) RETURN n"
		else
			query = "MATCH (n:#{class_name}:#{args.join(':')}) RETURN n"
		end
		transform_it(perform_request(query: query).rows)
	end

	def create_links(id:, type:, data: nil)
		hash = {id_1: self.id, id_2: id, data: data}
		query = "MATCH (n), (m) WHERE ID(n) = {id_1} AND ID(m) = {id_2}"
		query += "CREATE (n)-[:#{type.upcase} {timestamp: timestamp(), data: {data} }]->(m)"
		self.class.perform_request(query: query, hash: hash)
	end

	def self.where(*args, labels: "", equality: {})
		hash_map = {}
		if args.size ==  0 && equality.size == 0
			raise "please provide some argument to 'where' method #{__FILE__}:#{__LINE__}"
		end
		query = "MATCH (n:#{class_name + labels}) WHERE "
		equality.each do |k,v|
			args <<  "n." + k.to_s + " = {" + k.to_s + "} "
			hash_map[k] = equality.delete(k)
		end
		query += args.join(" AND ") 
		query += "RETURN n"
		transform_it(perform_request(query: query, hash: hash_map).rows)
	end

	def save
		hash_map = self.to_hash
		hash_map.delete(:id)
		self.class.perform_request(query: "MATCH (n) WHERE ID(n) = #{self.id} SET n = {hash}", hash: {:hash => hash_map})
	end

	def is_related_with(id:, type_of_link: "")
		hash = {id_1: self.id, id_2: id}
		query = "MATCH (n)-[r]-(m) WHERE ID(n) = {id_1} AND ID(m) = {id_2}"
		query += " AND type(r) = '" + type_of_link + "'"if !type_of_link.to_s.empty? && type_of_link.is_a?(String)
		query += " RETURN r"
		relation = self.class.perform_request(query: query, hash: hash).rows
	end


	def get_node_related_with(link:, type_of_node: [])
		query = "MATCH (n)-[:#{link}]-(m) WHERE "
		type_of_node.each_with_index do |type, index|
			query += (index  ==  0) ?  ""  : " OR "
			query += "m:"  + type 
		end
		query+= " AND " if type_of_node.any?
		query += " ID(n) = " + self.id.to_s + " RETURN m"
		self.class.query_transform(query: query)
	end

	def self.create(hash: {})
		if (self.cant_be_blank_on_creation - hash.keys).size != 0
			p self.cant_be_blank_on_creation, hash
			raise MatchaBase::Error, "missing argument on create"
		elsif (hash.keys - self.attributes).size != 0
			raise MatchaBase::Error, "too many argument on create"
		end
		hash.merge!(timestamp: Time.now.to_i)
		array_label = self.labels.map { |label| hash[label.to_sym] }
		query = "CREATE (n:#{class_name + array_label.map {|label| ":"+ label}.join.to_s } {hash}) RETURN n"
		transform_it(self.perform_request(query: query, hash: {hash: hash}).rows)
	end

	def self.find(id:)
		transform_it(perform_request(query: "MATCH (n:#{class_name}) WHERE ID(n) = {id} RETURN n", hash: {id: id}).rows).first
	end

	private
	def self.query_transform(query:, hash: {})
		transform_it(self.perform_request(query: query, hash: hash).rows)
	end

	def self.transform_it(*args)
		to_return = []
		args[0].each_with_index do |arg, index|
			model = arg[0].labels.select{|label| Module.constants.include?(label.capitalize)}
			model.any? ? model = Object.const_get(model[0].capitalize) : next
			to_return.push(model.new)
			model.attributes.each do |attr|
				if attr.to_s == 'id'
					to_return[index].send(attr.to_s + '=', arg[0].id)
				else
					to_return[index].send(attr.to_s + '=', arg[0].properties[attr])
				end
			end
		end
		to_return
	end

	def self.perform_request(query:, hash: {})
		puts query.blue + " "  + hash.to_s.yellow
		@@session.send('query', query, **hash)
	end
end
