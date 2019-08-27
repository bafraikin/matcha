
(function() {
	function normalize_data(data) {
		return (data.replace(/\+/g, '%2B'));
	}
	const update = function() {
		const node = this.parentNode.querySelector("p[contenteditable=true]");
		const csrf = document.querySelector("meta[name=csrf-token]").content;
		const req = new XMLHttpRequest();
		if (!node || !csrf) 
			return ;
		const id = node.id;
		const content = node.innerText;
		if (!id || !content || content == "")
			return;
		req.open('POST', '/user/update', true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);
		req.onreadystatechange = function(event) 
		{
			if (this.readyState === XMLHttpRequest.DONE)
			{
				if (!(this.status === 200 && this.response.match(/true/))) 
					console.log("display_error");
			}
		}
		req.send("id=" + id + "&content=" + content +  "&authenticity_token=" + normalize_data(csrf));
	}
	let inputs = document.querySelectorAll("input[value='save']");
	inputs.forEach(function (input) {
		input.addEventListener("click", update);
	});
})();
