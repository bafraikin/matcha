
(function () {
	function normalize_data(data) {
		return (data.replace(/\+/g, '%2B'));
	}
	const update = function () {
		const node = this.parentNode.querySelector("p[contenteditable=true]");
		const csrf = document.querySelector("meta[name=csrf-token]").content;
		const req = new XMLHttpRequest();
		if (!node || !csrf)
			return;
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
					console.log("display_error");
			}
		};
		req.send("id=" + id + "&content=" + content + "&authenticity_token=" + normalize_data(csrf));
	};


	const update_hashtag = function () {
		const csrf = document.querySelector("meta[name=csrf-token]").content;
		const req = new XMLHttpRequest();
		if (!csrf)
			return;
		req.open('POST', '/user/update_hashtag', true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);
		req.onreadystatechange = function (event) {
			if (this.readyState === XMLHttpRequest.DONE) {
				if (!(this.status === 200 && this.response.match(/true/)))
					console.log("display_error");
			}
		};
		req.send( "value=" + this.value + "&authenticity_token=" + normalize_data(csrf));
	};

	const update_sex = function () {
		const csrf = document.querySelector("meta[name=csrf-token]").content;
		const req = new XMLHttpRequest();
		if (!csrf)
			return;
		req.open('POST', '/user/update', true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);
		req.onreadystatechange = function (event) {
			if (this.readyState === XMLHttpRequest.DONE) {
				if (!(this.status === 200 && this.response.match(/true/)))
					console.log("display_error");
			}
		};
		req.send("id=sex" + "&content=" + this.value + "&authenticity_token=" + normalize_data(csrf));
	};

	let hashtag_input = document.querySelectorAll("input[type='checkbox']");
	hashtag_input.forEach(function (hashtag_input){ 
			hashtag_input.addEventListener("click", update_hashtag);
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