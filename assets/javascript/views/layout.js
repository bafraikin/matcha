

const addCariotToInput = function() 
{
	console.log("coucoiu");
	if (this) 
	{
		console.log(this);
		this.value += '\n';
	}
}



const displayChatMessages = function() {
	console.log("everything goes well");
}

const closeDiscussion = function() {
	this.parentNode.removeChild(this);
}

// {first_name:, hash_conv:, messages: [{}], src:}
const displayNewModalChat = function(objet) {
	const exemple  = document.querySelector("#exemple_chat_modal");
	const messenger = document.querySelector("#messenger");
	let toDisplay = exemple.cloneNode(true);
	toDisplay.classList.remove("invisible");
	toDisplay.id = objet.user_id;
	toDisplay.querySelector(".card-header span#first_name").innerHTML = objet.first_name;
	toDisplay.querySelector(".card-footer span").innerHTML = objet.hash_conv;
	toDisplay.querySelector(".card-body").innerHTML = displayChatMessages(objet.messages);
	toDisplay.querySelector(".card-footer textarea").onkeypress = HandleKeyPressChat;
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
