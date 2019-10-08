

const addCariotToInput = function() 
{
	if (this) 
	{
		console.log(this);
		this.value += '\n';
	}
}

const sendMessageToWorker = function()
{
	console.log(this);
}

const displayChatMessages = function() {
	console.log('everything goes well');
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
	toDisplay.id = "";
	toDisplay.querySelector(".card-header span#first_name").innerHTML = objet.first_name;
	toDisplay.querySelector(".card-footer span").innerHTML = objet.hash_conv;
	toDisplay.querySelector(".card-body").innerHTML = displayChatMessages(objet.messages);
	toDisplay.querySelector(".card-footer input").onkeypress = function(key) {
		if (!key.shiftKey && key.charCode == 13)
			sendMessageToWorker.bind(toDisplay)();
		else if (key.charCode == 13)
			addCariotToInput.bind(this)();
	}
	messenger.appendChild(toDisplay);
}
//displayNewModalChat({first_name: "Baptiste", hash_conv: "bdgd", src: "assets/pictures/cocou.jpg",  messages: [{user_id: "" }]}); to_test

// to test
//
const askForChatterToWorker = function () {
	if (!worker)
		return;
	worker.port.postMessage(JSON.stringify({type: "give_me_match"}));
}

window.onload = () => {
	const button = document.querySelector("#matcha_conv")
	if (button)
		button.addEventListener('click', function () {
			askForChatterToWorker();
		});
};
