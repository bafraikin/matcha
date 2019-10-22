module NotifHelper
	def send_notif_to(user:, notif:, from: nil, hash_conv: nil)
		return if !user.is_a?(User) || !is_connected?(user: user)
		settings.log.info("sending notif to #{user.key}")
		notif = notif.to_hash if notif.is_a?(Notification)
		notif.merge!(hash_conv: hash_conv) if hash_conv
		notif.merge!(from: from.full_name) if from
		settings.sockets[user.key].send(notif.to_json)
	end

	def new_websocket(user:)
		key = user.key
		request.websocket do |ws|
			ws.onopen do
				settings.sockets[key] = ws
			end
			ws.onclose do
				warn("websocket closed")
				settings.sockets.delete(key)
			end
		end
	end

	def send_socket_message_to(user:, body:, hash_conv:)
		return if !user.is_a?(User)
		notif = user.add_notification(type: "NEW_MESSAGE")
		if is_connected?(user: user)
			message = {type: "MESSAGE", body: body, hash_conv: hash_conv, user_id: user.id.to_s }
			settings.sockets[user.key].send(message.to_json)
			if notif.is_a?(Notification)
				settings.sockets[user.key].send(notif.to_hash.to_json)
			end
		end
	end

	def send_notif_match(first_user:, second_user:)
		notif = first_user.add_notification(type: "NEW_MATCH")
		notif_current = second_user.add_notification(type: "NEW_MATCH")
		send_notif_to(user: second_user, notif: notif, from: first_user)
		send_notif_to(user: first_user, notif: notif_current, from: second_user)
	end

	def send_notif_like(user_to_receive:)
		notif = user_to_receive.add_notification(type: "SOMEONE_LIKED_YOU")
		send_notif_to(user: user_to_receive, notif: notif)
	end

	def send_notif_view_to(user:)
		notif = user.add_notification(type: "SOMEONE_HAS_SAW_YOUR_PROFILE")
		send_notif_to(user: user, notif: notif)
	end

	def send_notif_unmatch(first_user:, second_user:, hash_conv:)
		notif = Notification.new(type: "UNMATCH")
		send_notif_to(user: second_user, notif: notif, hash_conv: hash_conv)
		send_notif_to(user: first_user, notif: notif, hash_conv: hash_conv)
	end
end
