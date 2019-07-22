require 'bundler/setup'
require "neo4j-core"
require 'neo4j/core/cypher_session/adaptors/http'
Dir["../lib/*.rb"].each {|file| require file }
require 'pry'

class MatchaBase 
	@@adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new('http://localhost:7474')
	@@session = Neo4j::Core::CypherSession.new(@@adaptor) 

	def self.attr_accessor(*vars)
		@attributes ||= []
		@attributes.concat vars
		super(*vars)
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

	def self.where(*args, labels: "", equality: {})
		if args.size ==  0 && equality.size == 0
			raise "please provide some argument to 'where' method #{__FILE__}:#{__LINE__}"
		end
		query = "MATCH (n:#{class_name + labels}) WHERE "
		equality.each do |k,v|
			args <<  "n." + k.to_s + " = '" + v + "' "
		end
		query += args.join(" AND ") 
		query += "RETURN n"
		transform_it(perform_request(query: query).rows)
	end

	private
	def self.transform_it(*args)
		to_return = []
		args[0].each_with_index do |arg, index|
			to_return.push(new)
			self.attributes.each do |attr|
				to_return[index].send(attr.to_s + '=', arg[0].properties[attr])
			end
		end
		to_return
	end

	def self.perform_request(query: "")
		puts query.blue
		@@adaptor.query(@@session, query)
	end
end
