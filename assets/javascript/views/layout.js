

const addCariotToInput = function() 
{
	console.log("coucoiu");
	if (this) 
	{
		console.log(this);
		this.value += '\n';
	}
}

const sendMessageToWorker = function()
{
	if (!this || !worker || !csrf)
		return;
	let input = this.querySelector('textarea');

}

const displayChatMessages = function() {
	console.log("everything goes well");
}

const closeDiscussion = function() {
	this.parentNode.removeChild(this);
}

// {first_name:, hash_conv:, messages: [{}], src:}
const displayNewModalChat = function(objet) {
	console.log(objet);
	const exemple  = document.querySelector("#exemple_chat_modal");
	const messenger = document.querySelector("#messenger");
	let toDisplay = exemple.cloneNode(true);
	toDisplay.classList.remove("invisible");
	toDisplay.id = "";
	toDisplay.querySelector(".card-header span#first_name").innerHTML = objet.first_name;
	toDisplay.querySelector(".card-footer span").innerHTML = objet.hash_conv;
	toDisplay.querySelector(".card-body").innerHTML = displayChatMessages(objet.messages);
	toDisplay.querySelector(".card-footer textarea").onkeypress = function(key) {
		if (!key.shiftKey && key.charCode == 13)
			sendMessageToWorker.bind(toDisplay)();
		else if (key.charCode == 13)
			addCariotToInput.bind(this)();
	}
	messenger.appendChild(toDisplay);
}

// to test
//
const askForChatterToWorker = function () {
	if (!worker)
		return;
	worker.port.postMessage({type: "give_me_match"});
}

window.onload = () => {
	const button = document.querySelector("#matcha_conv")
	if (button)
		button.addEventListener('click', function () {
			askForChatterToWorker();
		});
};
