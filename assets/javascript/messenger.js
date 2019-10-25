let csrf = document.querySelector("meta[name=csrf-token]").content;
let id_user = document.querySelector('#user_id').attributes.name.value;

const new_message = function (text, receiver) {
	return JSON.stringify({ data: text, receiver: receiver });
}



const openConv = function (user) {
	if (!(csrf && user && (user.user_id || user.user_id === 0) && user.src))
		return;
	worker.port.postMessage({ type: 'onpen_conv', user_id: user.user_id, src: user.src, csrf: normalize_data(csrf) });
};

const createBannerUser = function (exemple, user) {
	const clone = exemple.cloneNode(true);
	clone.querySelector("img").src = '/assets/pictures/' + user.src;
	clone.querySelector(".card-title").innerHTML = user.first_name;
	clone.querySelector(".card-text").innerHTML = "LAST MESSAGE";
	clone.id = "";
	clone.classList.remove('invisible');
	clone.addEventListener('click', () => openConv(user));
	return clone;
};

const displayMatchReadyForChat = function (data) {
	const div = document.getElementById('possible_conv_match');
	let exemple = document.getElementById('exemple_possible_conv');
	div.innerHTML = "";
	if (exemple)
		exemple = exemple.cloneNode(true);
	if (!div || !data.forEach || !exemple || data.length == 0)
		return;
	data.forEach((user) => {
		div.appendChild(createBannerUser(exemple, user));
	})
	div.appendChild(exemple);
}

const sendMessageToWorker = function () {
	if (!this || !worker || !csrf || !this.parentNode || !this.parentNode.parentNode || !/\S/.test(this.value))
		return;
	const div = this.parentNode.parentNode;
	if (!this.parentNode.querySelector)
		return;
	const span = this.parentNode.querySelector('span');
	worker.port.postMessage({ type: "SEND_MESSAGE", user_id: div.id, body: this.value, hash_conv: span.id, csrf: csrf });
}

const HandleKeyPressChat = function (event) {
	if (event.shiftKey && event.key == 'Enter')
		return;
	else if (event.key == 'Enter')
		sendMessageToWorker.bind(this)();
}

const Unmatched_chat = function (objet) {
	let isChatOpen = document.querySelector("span[id='" + objet.hash_conv + "']");
	if (!isChatOpen)
		return;
	let chat_body = isChatOpen.parentNode.parentNode;
	worker.port.postMessage({ type: "CLOSE_CONV", body: chat_body.id });
	chat_body.remove();
	if (window.innerWidth < 700)
		document.querySelector('#messenger').classList.remove('infront')
	alert("End of discussion");

}

const Update_chat = function (objet) {
	if (objet.bool == false) {
		Unmatched_chat(objet);
		return;
	}
	let isChatOpen = document.querySelector("span[id='" + objet.hash_conv + "']");
	if (!isChatOpen)
		return;
	let chat_body = isChatOpen.parentNode.parentNode.querySelector('#chat_body');
	let elem = document.createElement('p');
	if (objet.user_id == id_user) {
		elem.classList.add("py-1", "px-1", "rounded", "text-justify", "float-left", "bg-warning", "text-black");
		elem.id = "badge_chat_left";
	}
	else {
		isChatOpen.parentNode.querySelector('textarea').value = "";
		elem.classList.add("py-1", "px-1", "rounded", "text-justify", "float-right", "bg-primary", "text-white");
		elem.id = "badge_chat_right";
	}
	elem.innerText = decodeURI(objet.body);
	chat_body.appendChild(elem);
	chat_body.scrollTo(0, chat_body.scrollHeight);
}



const button_chat = document.querySelector("button[class='btn btn-outline-info message']");
if (button_chat)
	button_chat.addEventListener("click", openConv);
