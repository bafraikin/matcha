let connections = [];
let all_match = {};
let current_conversation = [];

const Socket = new WebSocket("ws://localhost:4567/user/socket");
Socket.onopen = function (event) {
	Socket.send("websocket instantie");
};
Socket.onmessage = function (event) {
	display_notif(event);
};

fetch('/user/matches_hashes').then((resp) => {
	resp.text().then(text => {
		if (text == "")
			return;
		all_match =JSON.parse(text);
	});
});

const handleMessage = function (port ,message) {
	if (!(message && message.data && message.data.type))
		return;
	let objet = message.data;
	switch (objet.type) {
		case 'onpen_conv':
			if (objet.user_id && objet.csrf)
			{
				let promise = openMessage(objet.user_id, objet.csrf);
				promise.then((data) =>  {
					if (data)
					port.postMessage(response)
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

//sharedworker est initialiser sur conv.js
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




/*
 *** my lib 
 */


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
/*
 *** end of lib
 */
