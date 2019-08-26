
(function() {
	const update = function() {
		const node = this.parentNode.querySelector("p[contenteditable=true]");
		debugger;
	}
	let inputs = document.querySelectorAll("input[value='save']");
		inputs.forEach(function (input) {
			input.addEventListener("click", update);
		});
})();
