const displayChatMessages = function (message_json, id, to_add) {
	let i = 0;
	let messages = [];
	while (message_json[i]) {
		let elem = document.createElement('p');
		if (message_json[i].id_user == id) {
			elem.classList.add("py-1", "px-1", "rounded", "text-justify", "float-left", "bg-warning", "text-black");
			elem.id = "badge_chat_left";
		}
		else {
			elem.classList.add("py-1", "px-1", "rounded", "text-justify", "float-right", "bg-primary", "text-white");
			elem.id = "badge_chat_right";
		}
		elem.innerText = decodeURI(message_json[i].body);
		messages.push(elem);
		i++;
	}
	messages.forEach(message => to_add.appendChild(message));
}

const closeDiscussion = function () {
	if (!(this && worker))
		return;
	worker.port.postMessage({ type: "CLOSE_CONV", body: this.id });
	this.parentNode.removeChild(this);
	if (window.innerWidth < 700)
		document.querySelector('#messenger').classList.remove('infront')
}

const display_conv = function (convs) {
	Object.keys(convs.body).forEach(conv => displayNewModalChat(convs.body[conv]));
}

// {first_name:, hash_conv:, messages: [{}], src:}
const displayNewModalChat = function (objet) {
	const exemple = document.querySelector("#exemple_chat_modal");
	const messenger = document.querySelector("#messenger");
	let toDisplay = exemple.cloneNode(true);
	toDisplay.classList.remove("invisible");
	if (window.innerWidth < 700)
		exemple.parentNode.classList.add('infront')
	toDisplay.id = objet.user_id;
	toDisplay.querySelector(".card-header span#first_name").innerHTML = objet.first_name;
	toDisplay.querySelector(".card-footer span").id = objet.hash_conv;
	displayChatMessages(objet.messages, objet.user_id, toDisplay.querySelector(".card-body"));
	toDisplay.querySelector(".card-footer textarea").onkeypress = HandleKeyPressChat;
	messenger.appendChild(toDisplay);
}

const getNotif = function () {
	fetch("/user/get_notif").then((resp) => resp.text().then((text) => {
		if (!(this && text && text != ""))
			return;
		const json = JSON.parse(text);
		const div = this.parentNode.querySelector("div");
		div.innerHTML = "";
		json.forEach(elem => div.innerHTML += '<p style="text-justify text-uppercase">' + elem.type.replace(/_/g, " ") + '</p>' + "<hr/>");
	}));
}

const askForChatterToWorker = function () {
	if (!worker)
		return;
	worker.port.postMessage({ type: "give_me_match" });
}

window.onload = () => {
	const button = document.querySelector("#matcha_conv")
	if (button)
		button.addEventListener('click', function () {
			askForChatterToWorker();
		});
}

window.onresize = function () {
	if (window.innerWidth > 700)
		document.querySelector('#messenger').classList.remove('infront');
	if (window.innerWidth < 700)
		document.querySelector('#messenger').classList.add('infront');
}