const worker = new SharedWorker("/assets/javascript/worker.js");
let csrf = document.querySelector("meta[name=csrf-token]").content;

const new_message = function (text, receiver) {
	return JSON.stringify({ data: text, receiver: receiver });
}

const send_text = function () {
	if (!this.parentNode)
		return;
	const input = this.parentNode.querySelector("input");
	const csrf = document.querySelector("meta[name=csrf-token]").content
	if (!input || input.value === "" || !csrf || !Socket)
		console.log("coucou");

}

window.onload = () => {
	const button = document.querySelector("#matcha_conv")
	if (button)
		button.onclick = function () {
			const input = document.createElement("input");
			const button = document.createElement("button");
			button.innerText = "envoyer";
			const div = document.createElement("div");
			div.append(input);
			div.append(button);
			button.onclick = send_text;
			document.body.append(div);
			this.classList.remove("active");
		}
};
/*
const sendMessage = function () {
	return fetch(url, {
		method: 'post',
		headers: {
			"Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
		},
		body: 'foo=bar&lorem=ipsum' + normalize_data(csrf),
	}).then(json)
		.then(function (data) {
			console.log('Request succeeded with JSON response', data);
		})
		.catch(function (error) {
			console.log('Request failed', error);
		});

}
*/


const openConv = function () {
	//worker.port.postMessage(['start', '1041' , document.querySelector("meta[name=csrf-token]").content])
	let id = document.querySelector('#user_id');
	if (!(csrf && id) )
		return;
	worker.port.postMessage(['start', id.getAttribute('value'), normalize_data(csrf)]);
};


const chat = document.querySelector('#input_chat');
if (chat)
	chat.addEventListener('keypress', function (event) {
		if (event.key != "Enter" || chat.value == "")
			return;
		worker.port.postMessage([chat.value, "id = 21"]);
		chat.value = "";
	})

worker.port.onmessage = function (msg) {
	if (msg.data == false)
		alert("You can't talk with people you didn't match with 😅")
	console.log(msg.data);

};


const button_chat = document.querySelector("button[class='btn btn-outline-info message']");
if (button_chat)
	button_chat.addEventListener("click", openConv);