let connections = [];
let all_match = {};
let current_conv = {isPrivate: false};
let socket;
let db;
let current_user_id;
let DBOpenRequest;
let csrf; 

indexedDB = indexedDB || mozIndexedDB || webkitIndexedDB || msIndexedDB; 
IDBTransaction = IDBTransaction || webkitIDBTransaction || msIDBTransaction;
IDBKeyRange = IDBKeyRange || webkitIDBKeyRange || msIDBKeyRange;

const prepareDB = function(callback) {
	DBOpenRequest = indexedDB.open("current_conv" + current_user_id, 1,{version: 1, storage: "persistent"});

	DBOpenRequest.onsuccess = function(event) {
		db = event.target.result;
		streamCurrentConv(stream_to_front);
	};
	DBOpenRequest.onupgradeneeded = function(event) {
		db = event.target.result;
		let objectStore = db.createObjectStore("current_conversation", {keyPath: "user_id"});
	};
	DBOpenRequest.onerror = function(event) {
		current_conv.isPrivate = true;
	}
};

const clear = function () {
	let objetStore = db.transaction("current_conversation", "readwrite");
	objetStore =  objetStore.objectStore("current_conversation");
	objetStore.clear();
}

const update_conv = function(objet) {
	if (objet && objet.user_id)
		objet["id_user"] = current_user_id;
	if (isPrivate())
		updateConvWorker(objet);
	else
		getAllConv(updateConvIndexDB.bind(objet));
}

const updateConvWorker = function(objet) {
	Object.keys(current_conv).forEach(function(key) {
		if (current_conv[key].hash_conv && current_conv[key].hash_conv && current_conv[key].hash_conv == objet.hash_conv)
		{
			current_conv[key].messages.push(objet);
			return;
		}
	});
}

const updateConvIndexDB = function(objet) {
	if (!(objet && objet.body && objet.body[0] && this && this.hash_conv))
		return;
	objet = objet.body;
	that = this;
	objet.forEach(function(obj) {
		if (obj.hash_conv == that.hash_conv)
		{
			obj.messages.push(that);
			addConv(obj, () => {});
			return;
		}
	});
}

const addConv = function(data, callback) {
	let transaction = db.transaction("current_conversation", "readwrite");
	let objectStore = transaction.objectStore("current_conversation");
	let request = objectStore.put(data);

	transaction.onabort = function(event) {
		current_conv.isPrivate = true;
		current_conv["user" + data.user_id] = data;
	}

	request.onsuccess = function(event) {
		callback();
	}

	request.onerror = function(event) {
	}
};

const getAllConv = function(callback, callbackError) {
	var transaction = db.transaction("current_conversation", "readonly");
	var objectStore = transaction.objectStore("current_conversation");
	var request = objectStore.getAll();
	request.onerror = function(event) {
		console.log("Unable to retrieve daa from database!");
	};
	request.onsuccess = function(event) {
		if(request.result) 
			callback({type: "CURRENT_CONV" , body: request.result});	
	};
}

const current_conversation = function(user_id, callback, callbackError) {
	if (isPrivate())
	{
		if (current_conv["user" + user_id])
			callbackError();
		else
			callback();
	}
	else
		getConv(user_id, callbackError, callback);
};

const getConv = function(user_id, callback, callback_error) {
	var transaction = db.transaction("current_conversation", "readonly");
	var objectStore = transaction.objectStore("current_conversation");
	var request = objectStore.get(parseInt(user_id));

	request.onerror = function(event) {
		console.log("Unable to retrieve daa from database!");
	};

	request.onsuccess = function(event) {
		if(request.result) 
			callback(request.result);
		else 
			callback_error();
	};
};

const tryRemoveConv = function(user_id) {
	getConv(user_id, removeConv, () => {});
};

const removeConv = function(conv) {
	var transaction = db.transaction("current_conversation", "readwrite");
	var objectStore = transaction.objectStore("current_conversation");
	objectStore.delete(conv.user_id);
}

const set_socket = function() {
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

const streamCurrentConv = function(callback) {
	if (isPrivate())
	{
		let tmp = {};
		let conv = {...current_conv};
		delete(conv.isPrivate);
		tmp["type"] = "CURRENT_CONV";
		tmp["body"] = conv;
		callback(tmp);
	}
	else
		getAllConv(callback, callback)
}

const get_match = function() {
	fetch('/user/matches_hashes').then((resp) => {
		resp.text().then(text => {
			if (text == "")
				return;
			all_match = JSON.parse(text);
		});
	});
}

const begin = function (object) {
	if ((object.data || object.data === 0) && !isNaN(object.data))
	{
		current_user_id = object.data;
		prepareDB();
	}
	else
		return;
}

const stream_to_front = function(to_stream) {
	connections.forEach(port => port.postMessage(to_stream));
};


const react_to_socket = function(event_ws) {
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
			update_conv(json);
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

const fetch_json = function(response) {
	return response.json()
}

const check_status = function(response) {
	if (response.status >= 200 && response.status < 300) {
		return Promise.resolve(response)
	} else {
		return Promise.reject(new Error(response.statusText))
	}
}

function normalize_data(data) {
	return (data.replace(/\+/g, '%2B'));
}

const open_conv = function (objet) {
	if ((objet.user_id || objet.user_id === 0) && csrf) {
		current_conversation(objet.user_id, function() {
			let promise = openMessage(objet.user_id, csrf);
			promise.then((data) => {
				if (!data)
					return;
				data['src'] = objet.src;
				data['user_id'] = objet.user_id;
				if (isPrivate())
				{
					current_conv["user" + objet.user_id] = data;
					data["type"] = "open_conv";
					stream_to_front(data);
				}
				else
				{
					let tmp = data;
					tmp["type"] = "open_conv";
					addConv(data, stream_to_front.bind(this, tmp));
				}
			});
		}, function() {
			stream_to_front({ type: "FALSE" });
		});
	}
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
		if (objet['bool'])
			update_conv(objet);
		stream_to_front(objet);
	}
	catch (error) {
		console.log('Request failed', error);
	}
}

const close_conv = function(object) {
	let id = object.body;
	if (isPrivate())
	{
		if (current_conv["user" + id])
			delete(current_conv["user" + id]);
	}
	else
		tryRemoveConv(id);
	stream_to_front({type: 'CLOSE_CONV', hash_conv: object.hash_conv, id: id});
}

const handleMessage = function (port, message) {
	if (!(message && message.data && message.data.type))
		return;
	let objet = message.data;
	switch (objet.type) {
		case 'open_conv':
			csrf = undefined;
			if (!(objet.csrf && objet.csrf != "")) 
				return ;
			csrf = objet.csrf;
			open_conv(objet)
			break;
		case 'give_me_match':
			port.postMessage({ type: "all_match", data: all_match });
			break;
		case 'SEND_MESSAGE':
			sendMessage(objet);
			break;
		case "CLOSE_CONV":
			close_conv(objet);
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
