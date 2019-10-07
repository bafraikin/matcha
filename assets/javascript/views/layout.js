

// need to sendMessageToWorker(), displayChatMessages() , addCariotToInput()
// {first_name:, hash_conv:, messages: [{}]}
const displayNewModalChat = function(objet) {
	const exemple  = document.querySelector("#exemple_chat_modal");
	const messenger = docuement.querySelector("#messenger");
	let toDisplay = exemple.cloneNode(true);
	to_display.classList.remove("invisible");
	to_display.querySelector(".card-header").innerHTML = objet.first_name;
	to_display.querySelector(".card-footer span").innerHTML = objet.hash_conv;
	to_display.querySelector(".card-body").innerHTML = displayChatMessages(objet.messages);
	to_display.querySelector(".card-footer input").onkeypress  = (key) => {
		if (!key.shiftKey && key.charCode == 13)
			sendMessageToWorker.bind(to_display)();
		else if (key.charCode == 13)
			addCariotToInput.bind(this)();
	}
}
