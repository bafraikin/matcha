let csrf = document.querySelector("meta[name=csrf-token]").content;

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
	const exemple = document.getElementById('exemple_possible_conv');
	const img = div.querySelector('img#loader_conv');
	if (!div || !data.forEach || !exemple || data.length == 0 || !img)
		return;
	img.parentNode.removeChild(img);
	data.forEach((user) => {
		div.appendChild(createBannerUser(exemple, user));
	})
}

const sendMessageToWorker = function () {
	if (!this || !worker || !csrf || !this.parentNode || !this.parentNode.parentNode)
		return;
	const div = this.parentNode.parentNode;
	if (!this.parentNode.querySelector)
		return;
	const span = this.parentNode.querySelector('span');
	worker.port.postMessage({type: "SEND_MESSAGE", user_id: div.id, body: this.value, hash_conv: span.innerHTML, csrf: csrf });
}

const HandleKeyPressChat = function (event) {
	if (event.shiftKey && event.key == 'Enter')
		return;
	else if (event.key == 'Enter')
		sendMessageToWorker.bind(this)();
}

const Update_chat = function (object){
	console.log(object);
}



const button_chat = document.querySelector("button[class='btn btn-outline-info message']");
if (button_chat)
	button_chat.addEventListener("click", openConv);
