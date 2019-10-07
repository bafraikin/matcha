
module NotifHelper
	def send_notif_to(user:, notif:, from: nil)
		return if !user.is_a?(User) || !is_connected?(user: user)
		settings.log.info("sending notif to #{user.key}")
		notif = notif.to_hash if notif.is_a?(Notification)
		notif.merge!(from: from.full_name) if from
		settings.sockets[user.key].send(notif.to_json)
	end

	def send_notif_to(user:, notif:, from: nil)
		return if !user.is_a?(User) || !is_connected?(user: user)
		settings.log.info("sending notif to #{user.key}")
		notif = notif.to_hash if notif.is_a?(Notification)
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

	def send_socket_message_to(user:, body:, hash:)
		return if !user.is_a?(User)
		notif = user.add_notification(type: "NEW_MESSAGE")
		if is_connected?(user: user)
			message = {type: "MESSAGE", body: body, hash: hash}
			settings.sockets[user.key].send(message.to_json)
		end
		if notif.is_a?(Notification)
			setting.sockets[user.key].send(notif.to_hash.to_json)
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
end
