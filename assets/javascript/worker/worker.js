let connections = [];
let all_match = {};
let current_conversation = [];
const Socket = new WebSocket("ws://localhost:4567/user/socket");

Socket.onopen = function (event) {
	Socket.send("websocket instantie");
};

Socket.onmessage = function (event_ws) {
	react_to_event(event_ws);
};

const get_match  = function() {
	fetch('/user/matches_hashes').then((resp) => {
		resp.text().then(text => {
			if (text == "")
				return;
			all_match =JSON.parse(text);
		});
	});
}

const stream_to_front = function(to_stream) {
	connections.forEach(port => port.postMessage(to_stream));
};


const react_to_event= function(event_ws) {
	if (!(event_ws && event_ws.is_Trusted && event_ws.data != ""))
		return;
	json = JSON.parse(event_ws.data);
	switch (json.type) {
		case 'NEW_MATCH':
			get_match();
			stream_to_front(json);
			break;
		case undefined:
			console.log('something_bad');
			break;
		default:
			console.log(json);
	}

}

const fetch_json = function (response) {
	return response.json()
}

const check_status = function (response) {
	if (response.status >= 200 && response.status < 300) {
		return Promise.resolve(response)
	} else {
		return Promise.reject(new Error(response.statusText))
	}
}

function normalize_data(data) {
	return (data.replace(/\+/g, '%2B'));
}

const handleMessage = function (port, message) {
	if (!(message && message.data && message.data.type))
		return;
	let objet = message.data;
	switch (objet.type) {
		case 'onpen_conv':
			if ((objet.user_id || objet.user_id === 0) && objet.csrf)
			{
				let promise = openMessage(objet.user_id, objet.csrf);
				promise.then((data) =>  {
					if (!data)
						return;
					data['src'] = objet.src;
					data['user_id'] = objet.user_id;
					current_conversation.push(data);
					data['type'] = "open_conv";
					port.postMessage(data);
				});	
			}
			break;
		case 'give_me_match':
			port.postMessage({type: "all_match", data: all_match});
			break;
		default:
			connections.forEach(connection => connection.postMessage(objet.type));
	}
}

onconnect = function (e) {
	connections.push(e.ports[0]);
	const port = e.ports[0];
	port.start();
	port.onmessage = function(message) {
		handleMessage(port, message);
	}
}

const openMessage = function (id, csrf) {
	return fetch("/user/open_message?id=" + id + "&authenticity_token=" + normalize_data(csrf))
		.then(check_status)
		.then(fetch_json)
		.then(function (data) {
			return data;
		}).catch(function (error) {
			return false;
		});
};


get_match();
