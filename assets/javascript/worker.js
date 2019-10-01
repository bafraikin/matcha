let connections = [];
const Socket = new WebSocket("ws://localhost:4567/user/socket");
Socket.onopen = function (event) {
	Socket.send("websocket instantie"); 
};
Socket.onmessage = function (event) {
//	display_notif(event);
};


onconnect = function (e) {
	if (connection.lenght == 0)
		init();
	connection.push(e.ports[0]);
	const port = e.ports[0];
	port.start();
}
