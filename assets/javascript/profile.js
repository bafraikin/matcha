
(function () {
	function normalize_data(data) {
		return (data.replace(/\+/g, '%2B'));
	}
	const update = function () {
		const node = this.parentNode.querySelector("p[contenteditable=true]");
		let csrf = document.querySelector("meta[name=csrf-token]");
			if (!node || !csrf)
				return;
		csrf = csrf.content;
		const req = new XMLHttpRequest();
		const id = node.id;
		const content = node.innerText;
		if (!id || !content || content == "")
			return;
		req.open('POST', '/user/update', true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);
		req.onreadystatechange = function (event) {
			if (this.readyState === XMLHttpRequest.DONE) {
				if (!(this.status === 200 && this.response.match(/true/)))
					alert(this.response);
			}
		};
		req.send("id=" + id + "&content=" + encodeURI(content) + "&authenticity_token=" + normalize_data(csrf));
	};


	const update_checkbox = function () {
		let csrf = document.querySelector("meta[name=csrf-token]");
		const req = new XMLHttpRequest();
		const id = this.id;
		if (!csrf)
			return;
		csrf = csrf.content;
		req.open('POST', '/user/update_hashtag', true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);
		req.onreadystatechange = function (event) {
			if (this.readyState === XMLHttpRequest.DONE) {
				if (!(this.status === 200 && this.response.match(/true/)))
					alert(this.response);
			}
		};
		req.send( "id=" + encodeURI(id) + "&value=" + this.value + "&authenticity_token=" + normalize_data(csrf));
	};

	const update_sex = function () {
		let csrf = document.querySelector("meta[name=csrf-token]");
		if (!csrf)
			return;
		csrf = csrf.content;
		const req = new XMLHttpRequest();
		req.open('POST', '/user/update', true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);
		req.onreadystatechange = function (event) {
			if (this.readyState === XMLHttpRequest.DONE) {
				if (!(this.status === 200 && this.response.match(/true/)))
					alert(this.response);
			}
		};
		req.send("id=sex" + "&content=" + encodeURI(this.value) + "&authenticity_token=" + normalize_data(csrf));
	};

	let hashtag_input = document.querySelectorAll("input[type='checkbox']");
	hashtag_input.forEach(function (hashtag_input){ 
		hashtag_input.addEventListener("click", update_checkbox);
	});

	let inputs = document.querySelectorAll("input[value='save']");
	inputs.forEach(function (input) {
		input.addEventListener("click", update);
	});

	let sex = document.querySelectorAll("option")
		sex.forEach(function (sex) { 
			sex.addEventListener("click", update_sex);
		});
})();
