
module ValidatorHelper
	def to_proprety(method)
		method.to_s[/(?<=valid_)[^?]+/].to_sym
	end

	def validator(hash: {})
		methods = Object.const_get(self.name + 'Helper::Validator').instance_methods
		invalid = methods.select do |method|
			!self.send(method, hash[to_proprety(method)])
		end.map{|method| to_proprety(method).to_s}
	end

	def error_message(array:)
		methods = Object.const_get(self.name + 'Helper::DisplayError').instance_methods
		array.select{|proprety| methods.include?(('error_' + proprety).to_sym)}.map{|proprety| self.send('error_' + proprety)}
	end
end
