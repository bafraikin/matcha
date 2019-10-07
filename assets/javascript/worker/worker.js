let connections = [];
const Socket = new WebSocket("ws://localhost:4567/user/socket");
Socket.onopen = function (event) {
	Socket.send("websocket instantie");
};
Socket.onmessage = function (event) {
	display_notif(event);
};

//sharedworker est initialiser sur conv.js
onconnect = function (e) {
	connections.push(e.ports[0]);
	const port = e.ports[0];
	port.start();
	port.onmessage = function (e) {
		//getting data 
		if (e.data[0] && e.data[0] == 'start' && e.data[1] && e.data[2]) {
			let promise = openMessage(e.data[1], e.data[2]);
			promise.then((response) => { port.postMessage(response) });
			// il faut aussi stocker la data reçu
		}
		else if (e.data[0] && e.data[0] != 'start' && e.data[1]) {
			
		}
		else
			connections.forEach(connection => { /* send data to all current terminal in case of regulare msg*/
				connection.postMessage(e.data);
			});
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

const json = function (response) {
	return response.json()
}

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
