

const new_message = function (text, receiver) {
	return JSON.stringify({data: text, receiver: receiver});
}

const send_text = function () {
	if (!this.parentNode)
		return;
	const input = this.parentNode.querySelector("input");
	const csrf = document.querySelector("meta[name=csrf-token]").content
	if (!input || input.value === "" || !csrf || !Socket)

}

window.onload = () => {
	document.querySelector("#matcha_conv").onclick = function() {
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



