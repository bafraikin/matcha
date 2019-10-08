let connections = [];
let all_match = {};

const Socket = new WebSocket("ws://localhost:4567/user/socket");
Socket.onopen = function (event) {
	Socket.send("websocket instantie");
};
Socket.onmessage = function (event) {
	display_notif(event);
};

fetch('/user/matches_hashes').then((resp) => {
	if (resp != "")
		resp.json().then ((json) => {
			all_match = json;
		});
});

const handleMessage = function (port ,message) {
	if (message.data == "" )
		return;
	let json = JSON.parse(message.data);
	if (message.data[0] && message.data[0] == 'start' && message.data[1] && message.data[2]) 
	{
		/*
		let promise = openMessage(message.data[1], message.data[2]);
		promise.then((response) => { port.postMessage(response) }); */
		// il faut aussi stocker la data reçu
	}
	else if (json.type == "give_me_match") 
	{
		port.postMessage(JSON.stringify({type: "all_match", data: all_match}));
	}
	else 
	{
		connections.forEach((connection) => 
			{ /* send data to all current terminal in case of regulare msg*/
				connection.postMessage(json.type);
			});
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
		.then(status)
		.then(json)
		.then(function (data) {
			return data;
		}).catch(function (error) {
			return false;
		});
};




/*
 *** my lib 
 */

/*
const json = function (response) {
	return response.json()
}
*/
const status = function (response) {
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
