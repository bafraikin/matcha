let connections = [];
const Socket = new WebSocket("ws://localhost:4567/user/socket");
Socket.onopen = function (event) {
	Socket.send ("websocket instantie"); 
};
Socket.onmessage = function (event) {
	display_notif(event);
};

//sharedworker est initialiser sur conv.js
onconnect = function (e) {
	connections.push(e.ports[0]);
	const port = e.ports[0];
	port.start();
	port.onmessage = function(e) { 
		connections.forEach(connection => {
				connection.postMessage(e.data);
	});
}

}
