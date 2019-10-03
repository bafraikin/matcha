const worker = new SharedWorker("./assets/javascript/worker.js");

const new_message = function (text, receiver) {
	return JSON.stringify({data: text, receiver: receiver});
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
			button.onclick = function() {
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


 let chat = document.querySelector('#input_chat');

 chat.addEventListener('keypress', function(event){
	if(event.key != "Enter" || chat.value == "")
		return;
	worker.port.postMessage([chat.value, "id = 21"]);
	chat.value = "";
	})

	worker.port.onmessage = function (msg) {
		console.log(msg.data);
	};
