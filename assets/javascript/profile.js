
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

	function  handle_file() {
		const input = document.querySelector('input[type=file]');
		let button = document.querySelector('div#upload button');
	//	send_it(button);
		let files = input.files;
		if (files.length > 1 || files[0].size > 50000000 || !files[0].type.match(/(jpeg|jpg|png)/))
			dont_send_it(button);
	}

	function dont_send_it(button) {
		button.removeEventListener('click', upload_photo);
		button.style.backgroundColor = 'red';
	}

	function send_it(button) {
		button.addEventListener('click', upload_photo);
		button.style.backgroundColor = 'initial';
	}

	function display_photo_uploaded(response) {
		if (!!response.match(/error/))
			return ;
		const div = document.querySelector('div.video');
		const video = document.querySelector('#video');
		const startbutton = document.querySelector('.startbutton');
		let img = document.querySelector('#uploaded');
		if (!!video)
			video.parentNode.removeChild(video);
		if (!img)
		{
			img = document.createElement('img');
			let button = document.createElement('button');
			button.textContent = 'Monter';
			button.style.width = "100%";
			img.id = 'uploaded';
			startbutton.append(button);
			div.append(img);
			button.addEventListener('click', mount_them);
		}
		img.src = '/galerie/tmp/' + response;
	}

	function getBase64(file) {
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.readAsDataURL(file);
			reader.onload = () => resolve(reader.result);
			reader.onerror = (error) => reject(error);
		});
	}

	function upload_photo() {
		let photo = document.querySelector('input[type=file]').files[0];
		let req = new XMLHttpRequest();
		var form_data = new FormData();        
		req.open("POST", '/galerie/php/upload_photo.php', true);
		req.overrideMimeType("text/plain;");
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.onreadystatechange = function(event) {
			if (this.readyState === XMLHttpRequest.DONE) {
				if (this.status === 200 && !this.response.match(/error/)) {
					display_photo_uploaded(this.response);
				} 
			}
		};
		getBase64(photo)
			.then((data) => {
				req.send('file=' +  normalize_data(data));
			})
		.catch(error => console.error(error));
	}

	function create_button_upload() {
		let div = document.querySelector('div#picture');
		div.innerHTML += '<div id="upload"><p>(100Ko max)</p><input type="file" name="picture" accept="image/jpg|image/png|image/jpeg"><button>send</button></div>';
		let input = document.querySelector('input[type=file]');
		input.addEventListener('change', handle_file);
	}

	create_button_upload();
	let inputs = document.querySelectorAll("input[value='save']");
	inputs.forEach(function (input) {
		input.addEventListener("click", update);
	});
})();
