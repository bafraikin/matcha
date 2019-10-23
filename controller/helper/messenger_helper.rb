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

	def suppr_talker(talker:)
		session[:messenger][:number] = session[:messenger][:number].to_i - 1
		if !(session[:messenger][:talker].nil?)
			session[:messenger][:talker].delete("user#{talker.id}".to_sym)
		end
		session[:messenger]
	end
	
	def user_message_to(user:, hash:, body:)
		return false if !is_messenger_ready? || session[:messenger][:talker].nil? || session[:messenger][:talker][user.key].nil?
		messenger =  session[:messenger][:talker][user.key]
		if messenger.still_exist?
			if match = current_user.is_match_with(user_id: user.id)
				if match.properties[:data] == messenger.match_hash
					messenger.new_message(id_user: current_user.id, body: body)
					return true
				end
			end
		end
		false
	end
end
