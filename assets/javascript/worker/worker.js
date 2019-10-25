let connections = [];
let all_match = {};
let current_conv = {isPrivate: false};
let socket;
let db;
let current_user_id;
let DBOpenRequest;

indexedDB = indexedDB || mozIndexedDB || webkitIndexedDB || msIndexedDB; 
IDBTransaction = IDBTransaction || webkitIDBTransaction || msIDBTransaction;
IDBKeyRange = IDBKeyRange || webkitIDBKeyRange || msIDBKeyRange


const prepareDB = function() {
	DBOpenRequest = indexedDB.open("current_conv" + current_user_id);
	DBOpenRequest.onsuccess = function(event) {
		console.log("we created db")
	}
	DBOpenRequest.onupgradeneeded = function(event) {
		var db = event.target.result;
		var objectStore = db.createObjectStore("current_conversation", { keyPath: "id" });
	};
	DBOpenRequest.onerror = function(event) {
		current_conv.isPrivate = true;
	}
}

function addData(data) {
	var request = db.transaction("current_conversation", "readwrite")
		.objectStore("current_conversation")
		.add(data);

	request.onsuccess = function(event) {
		console.log(we did it);
	};

	request.onerror = function(event) {
		console.log("Unable to add data\r\nPrasad is already exist in your database! ");
	}
}

function read(name) {
	var transaction = db.transaction("current_conversation", "read");
	var objectStore = transaction.objectStore("current_conversation");
	var request = objectStore.get(name);

	request.onerror = function(event) {
		console.log("Unable to retrieve daa from database!");
	};

	request.onsuccess = function(event) {
		if(request.result) {
			console.log(request.result);
		} else {
			console.log("Kenny couldn't be found in your database!");
		}
	};
}


const set_socket = function () {
	if (!socket) {
		socket = new WebSocket("ws://localhost:4567/user/socket");

		socket.onopen = function (event) {
			socket.send("websocket instantie");
		};

		socket.onmessage = function (event_ws) {
			react_to_socket(event_ws);
		};
	}
}
set_socket();

const isPrivate = function() {
	return current_conv.isPrivate;
}

const get_match = function () {
	fetch('/user/matches_hashes').then((resp) => {
		resp.text().then(text => {
			if (text == "")
				return;
			all_match = JSON.parse(text);
		});
	});
}

const begin = function (object) {
	if (!(object.data && !isNaN(object.data)))
		debugger;
	current_user_id = object.data;
	prepareDB();
}

const stream_to_front = function (to_stream) {
	connections.forEach(port => port.postMessage(to_stream));
};


const react_to_socket = function (event_ws) {
	if (!(event_ws && event_ws.isTrusted && event_ws.data != ""))
		return;
	json = JSON.parse(event_ws.data);
	switch (json.type) {
		case 'NEW_MATCH':
			get_match();
			stream_to_front(json);
			break;
		case 'SOMEONE_LIKED_YOU':
			stream_to_front(json);
			break;
		case 'SOMEONE_HAS_SAW_YOUR_PROFILE':
			stream_to_front(json);
			break;
		case 'ERROR':
			stream_to_front(json);
			break;
		case 'NEW_MESSAGE':
			stream_to_front(json);
			break;
		case 'MESSAGE':
			stream_to_front(json);
			break;
		case 'UNMATCH':
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

const open_conv = function (port, objet) {
	if ((objet.user_id || objet.user_id === 0) && objet.csrf && !current_conversation["user" + objet.user_id]) {
		let promise = openMessage(objet.user_id, objet.csrf);
		promise.then((data) => {
			if (!data)
				return;
			data['src'] = objet.src;
			data['user_id'] = objet.user_id;
			current_conversation["user" + objet.user_id] = data;
			data['type'] = "open_conv";
			port.postMessage(data);
		});
	}
	else
		port.postMessage({ type: "FALSE" });
}

const sendMessage = async function (objet) {
	try {
		objet.body = encodeURI(objet.body);
		const response = await fetch("/user/send_message", {
			method: 'post',
			headers: {
				'X-Requested-With': 'XMLHttpRequest',
				"Content-type": "application/json ; charset=UTF-8",
				"X-CSRF-Token": objet.csrf
			},
			body: JSON.stringify({ hash: objet.hash_conv, user_id: objet.user_id, body: objet.body }),
		});
		objet['bool'] = await fetch_json(response);
		objet['type'] = "MESSAGE";
		stream_to_front(objet);
	}
	catch (error) {
		console.log('Request failed', error);
	}
}

const close_conv = function(id) {
	if (current_conversation["user" + id])
		delete(current_conversation["user" + id]);
}

const handleMessage = function (port, message) {
	if (!(message && message.data && message.data.type))
		return;
	let objet = message.data;
	switch (objet.type) {
		case 'onpen_conv':
			open_conv(port, objet)
			break;
		case 'give_me_match':
			port.postMessage({ type: "all_match", data: all_match });
			break;
		case 'SEND_MESSAGE':
			sendMessage(objet);
			break;
		case "CLOSE_CONV":
			close_conv(objet.body);
			break;
		case 'get_message':
			break;
		case 'YOU_WERE_READY':
			begin(objet);
			break;
		default:
			connections.forEach(connection => connection.postMessage(objet.type));
	}
}

onconnect = function (e) {
	connections.push(e.ports[0]);
	if (navigator.userAgent.match(/firefox/i))
		set_socket();
	const port = e.ports[0];
	port.start();
	//port.postMessage({ type: "CURRENT_CONV", body: current_conversation});
	port.onmessage = function (message) {
		handleMessage(port, message);
	}
	port.postMessage({type: "IM_READY"});
}

const openMessage = async function (id, csrf) {
	try {
		const response = await fetch("/user/open_message?id=" + id + "&authenticity_token=" + normalize_data(csrf));
		const response_1 = await check_status(response);
		const data = await fetch_json(response_1);
		return data;
	}
	catch (error) {
		return false;
	}
};



get_match();
