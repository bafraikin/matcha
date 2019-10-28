intervals = {};

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

const tryDiscussion = function () {
	if (!(this && worker))
		return;
	worker.port.postMessage({ type: "CLOSE_CONV", body: this.id, hash_conv: this.querySelector('span.invisible').id });
}

const closeDiscussion = function (objet) {
	let isChatOpen = document.querySelector("span[id='" + objet.hash_conv + "']");
	if (!isChatOpen)
		return;
	let chat_body = isChatOpen.parentNode.parentNode;
  clearInterval(intervals["user" + this.id]);
	delete(intervals["user" + this.id]);
	chat_body.remove();
}

const display_conv = function (convs) {
	Object.keys(convs.body).forEach(conv => displayNewModalChat(convs.body[conv]));
}

const displayNewModalChat = function (objet) {
	const exemple = document.querySelector("#exemple_chat_modal");
	const messenger = document.querySelector("#messenger");
	if (!(exemple && messenger && !(Array.from(document.querySelectorAll("#messenger span.invisible")).filter(elem => elem.id == objet.hash_conv).length)))
		return;
	let toDisplay = exemple.cloneNode(true);
	toDisplay.classList.remove("invisible");
	if (window.innerWidth < 700)
		exemple.parentNode.classList.add('infront')
	toDisplay.id = objet.user_id;
	toDisplay.querySelector(".card-header div span#first_name").innerHTML = objet.first_name;
	intervals["user" + objet.user_id] = setInterval(isOnline.bind(toDisplay.querySelector(".card-header div"), objet.user_id), 5000);
	toDisplay.querySelector(".card-footer span").id = objet.hash_conv;
	displayChatMessages(objet.messages, objet.user_id, toDisplay.querySelector(".card-body"));
	toDisplay.querySelector(".card-footer textarea").onkeypress = HandleKeyPressChat;
	messenger.appendChild(toDisplay);
}

const updateChat = function(that, text) {
	if (!(that && text && text != ""))
		return;
	if (text.match(/true/))
		that.querySelector("#status").innerHTML = "<div class='text-success'><i class='fa fa-bandcamp'></i></div>"
	else
		that.querySelector("#status").innerHTML =  "<div class='text-muted'>il y a " + Math.floor((new Date().getTime() - (JSON.parse(text) * 1000)) / 1000 / 60) + " min</div>";
}

const isOnline = function(id) {
	if (!this)
		return;
	const that = this;
	fetch("/user/is_online/" + id).then(resp => resp.text().then((text) => {
			updateChat(that, text);
	}
	).catch(error => console.log(error, 1))).catch(error => console.log(error));
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