let csrf = document.querySelector("meta[name=csrf-token]").content;

const new_message = function (text, receiver) {
	return JSON.stringify({ data: text, receiver: receiver });
}

/*
const sendMessage = function () {
	return fetch(url, {
		method: 'post',
		headers: {
			"Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
		},
		body: 'foo=bar&lorem=ipsum' + normalize_data(csrf),
	}).then(json)
		.then(function (data) {
			console.log('Request succeeded with JSON response', data);
		})
		.catch(function (error) {
			console.log('Request failed', error);
		});

}
*/

const openMessage = function(id) {
	const myInit = { method: 'GET',cache: 'default' };
	let csrf = document.querySelector("meta[name=csrf-token]");
	if (csrf)
		csrf = csrf.content
	else
		return;
	// test if json return "" maybe it will raise an error
	fetch("/user/open_message?id=" + id + "&authenticity_token=" + normalize_data(csrf), myInit).then((response) => {
		response.json().then((json) => {
			if (json.type)
				;
		});
	});
}

const createBannerUser = function(exemple, user) {
	const clone = exemple.cloneNode(true);
	clone.querySelector("img").src= '/assets/pictures/' + user.src;
	clone.querySelector("div span").innerHTML= user.first;
	clone.classList.remove('invisible');
	return clone;
};

const displayMatchReadyForChat = function(data) {
	const div = document.getElementById('possible_conv_match');
	const exemple = document.getElementById('exemple_possible_conv');
	const img = div.querySelector('img#loader_conv');
	if (!div || !data.forEach || !exemple)
		return;
	img.parentNode.removeChild(img);
	data.forEach((user) => {
		div.appendChild(createBannerUser(exemple, user));
	})
}

const openConv = function () {
	//worker.port.postMessage(['start', '1041' , document.querySelector("meta[name=csrf-token]").content])
	let id = document.querySelector('#user_id');
	if (!(csrf && id) )
		return;
	worker.port.postMessage(['start', id.getAttribute('value'), normalize_data(csrf)]);
};


const chat = document.querySelector('#input_chat');
if (chat)
	chat.addEventListener('keypress', function (event) {
		if (event.key != "Enter" || chat.value == "")
			return;
		worker.port.postMessage([chat.value, "id = 21"]);
		chat.value = "";
	})



const button_chat = document.querySelector("button[class='btn btn-outline-info message']");
if (button_chat)
	button_chat.addEventListener("click", openConv);
