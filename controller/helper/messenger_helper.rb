module MessengerHelper
	def add_new_talker(talker, id_conv)
		messenger = Messenger.where(equality: {match_hash: id_conv})
		return session[:messenger] if !(messenger.any? && messenger[0].is_a?(Messenger))
		session[:messenger][:number] = session[:messenger][:number].to_i + 1
		session[:messenger][:talker][:"user#{talker.id}"] = messenger[0]
		session[:messenger]
	end

	def is_messenger_ready?
		!session[:messenger].nil?
	end

	def create_messenger
		session.store(:messenger, Hash.new)
		session[:messenger][:talker] = Hash.new
		session[:messenger]
	end

	def prepare_messenger
		unless is_messenger_ready?
			session[:messenger] = create_messenger
		end
		session[:messenger]
	end

	def suppr_talker(talker)
		session[:messenger][:number] = session[:messenger][:number].to_i - 1
		if !(session[:messenger][:talker].nil?)
			session[:messenger][:talker].delete!("user#{talker.id}".to_sym)
		end
		session[:messenger]
	end
end
