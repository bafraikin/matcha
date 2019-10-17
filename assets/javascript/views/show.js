function send_like(id)
{
	const req = new XMLHttpRequest();
	const csrf = document.querySelector("meta[name=csrf-token]").content
	if (isNaN(id) && !!csrf)
		return;
	req.open('POST', '/user/toggle_like', true);
	req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);

	req.onreadystatechange = function(event) 
	{
		if (this.readyState === XMLHttpRequest.DONE)
		{
			if (this.status === 200) 
				console.log("Réponse recu");
			else 
				console.log("Status de la réponse: %d (%s)", this.status, this.statusText);
		}
	}
	req.send("id=" + encodeURI(id) + "&authenticity_token=" + normalize_data(csrf));
}

function  handle_file() {
	const input = document.querySelector('input[type=file]');
	let button = document.querySelector('span#inputGroupFileAddon01');
	send_it(button);
	let files = input.files;
	if (files.length > 1 || files[0].size > 50000000 || !files[0].type.match(/(jpeg|jpg|png)/))
		dont_send_it(button);
}

const reportUser = async function(id) {
	if (!(!isNaN(id) && csrf))
		return;
	const myInit = { method: 'POST',
		headers: {
			'X-Requested-With': 'XMLHttpRequest',
			"Content-type": "application/json ; charset=UTF-8",
			"X-CSRF-Token": csrf
		},
		body: JSON.stringify({user_id: id}),
	};
	const response = await fetch('/user/report_user', myInit);
}

function dont_send_it(button) {
	button.removeEventListener('click', upload_photo);
	button.style.backgroundColor = 'red';
}

function send_it(button) {
	button.addEventListener('click', upload_photo);
	button.style.backgroundColor = 'initial';
}

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
	}
	req.send("id=" + encodeURI(id) + "&content=" + encodeURI(content) +  "&authenticity_token=" + normalize_data(csrf));
}


function display_photo_uploaded(response) {
	if (!!response.match(/error/))
		return ;
	const div = document.querySelector('div.card.general-card');
	const picture_div = document.querySelector('#picture');
	if (response && div && picture_div)
	{
		let new_div = div.cloneNode(true);
		new_div.querySelector('img').src = "/assets/pictures/" + response;
		picture_div.append(new_div);
	}
}

function getBase64(file) {
	return new Promise((resolve, reject) => {
		const reader = new FileReader();
		reader.readAsDataURL(file);
		reader.onload = () => resolve(reader.result);
		reader.onerror = (error) => reject(error);
	});
}

function toggle_profile() {
	const csrf = document.querySelector("meta[name=csrf-token]")
	if (!csrf || !csrf.content || !this || !this.parentNode || this.classList.contains('btn-secondary') || !this.parentNode.parentNode)
		return ;
	let button = this;
	let img = this.parentNode.parentNode.querySelector('img');
	if (!img || !img.id || isNaN(img.id))
		return ;
	let req = new XMLHttpRequest();
	req.open("POST", '/user/toggle_profile', true);
	req.overrideMimeType("text/plain;");
	req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	req.onreadystatechange = function(event) {
		if (this.readyState === XMLHttpRequest.DONE) {
			if (this.status === 200 && !this.response.match(/error/)) {
				const ancient_profile_picture = document.querySelector('.btn-secondary');
				if (ancient_profile_picture)
				{
					button.classList.remove('btn-info');
					button.classList.add('btn-secondary');
					ancient_profile_picture.classList.add('btn-info');
					ancient_profile_picture.classList.remove('btn-secondary');
				}
			}
		}
	}
	req.send('id=' + img.id  + "&authenticity_token=" + normalize_data(csrf.content));
}

function delete_this_picture() {
	const csrf = document.querySelector("meta[name=csrf-token]")
	if (!csrf || !csrf.content || !this || !this.parentNode || !this.parentNode.parentNode)
		return ;
	const div = this.parentNode.parentNode;
	const img = div.querySelector('img');
	if (!img)
		return ;
	let req = new XMLHttpRequest();
	req.open("POST", '/user/delete_photo', true);
	req.overrideMimeType("text/plain;");
	req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	req.onreadystatechange = function(event) {
		if (this.readyState === XMLHttpRequest.DONE) {
			if (this.status === 200 && !this.response.match(/error/)) {
				div.parentNode.removeChild(div);
			}
		}
	}
	req.send('src=' + img.src  + "&authenticity_token=" + normalize_data(csrf.content));
}

function upload_photo() {
	let photo = document.querySelector('input[type=file]').files[0];
	const csrf = document.querySelector("meta[name=csrf-token]")
	if (!csrf || !csrf.content || !photo)
		return;
	let req = new XMLHttpRequest();
	req.open("POST", '/user/add_photo', true);
	req.overrideMimeType("text/plain;");
	req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	req.onreadystatechange = function(event) {
		if (this.readyState === XMLHttpRequest.DONE) {
			if (this.status === 200 && !this.response.match(/error/) && this.response != "") {
				display_photo_uploaded(this.response);
			} 
		}
	};
	getBase64(photo)
		.then((data) => {
			req.send('file=' +  normalize_data(data) + "&authenticity_token=" + normalize_data(csrf.content));
		})
		.catch(error => console.error(error));
}

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
	req.send( "id=" + encodeURI(id) + "&value=" + encodeURI(this.value) + "&authenticity_token=" + normalize_data(csrf));
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

(function(){
	let hashtag_input = document.querySelectorAll("input[type='checkbox']");
	hashtag_input.forEach(function (hashtag_input){ 
		hashtag_input.addEventListener("click", update_checkbox);
	});

	let inputs = document.querySelectorAll("input[value='save']");
	let buttons_profile = document.querySelectorAll('button.profile_picture');
	let delete_picture = document.querySelectorAll('button.delete_picture');

	inputs.forEach(function (input) {
		input.addEventListener("click", update);
	});
	buttons_profile.forEach(function (input) {
		input.addEventListener("click", toggle_profile);
	});
	delete_picture.forEach(function (input) {
		input.addEventListener("click", delete_this_picture);
	});

	let sex = document.querySelectorAll("select")
	sex.forEach(function (sex) { 
		sex.addEventListener("change", update_sex);
	});
})();
