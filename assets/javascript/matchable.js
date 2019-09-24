

(function () {
	function normalize_data(data) {
		return (data.replace(/\+/g, '%2B'));
	}

	function construct_card(user) {
		let div = document.getElementById("exemple");
		if (!div)
			return ;
		div = div.cloneNode(true);
		div.querySelector("h5.card-title").innerText = user.first_name;
		div.querySelector("p.text-truncate").innerText = user.biography;
		div.querySelector("button").onclick = function() { window.location= '/user/show/'+ user.id; }
		div.querySelector("img").id = user.id
			div.style = "display: flex"; 
		return (div);
	}

	const display_profile_picture = function (response) {
		this.querySelector("img").src = "assets/pictures/" + JSON.parse(response)
	}

	const load_photo = function() {
		const that = this;
		this.classList.remove('to_load');
		const req = new XMLHttpRequest();
		const csrf = document.querySelector("meta[name=csrf-token]").content;
		const img = this.querySelector('img');
		req.open('GET', '/user/get_profile_picture/' + img.id, true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.onreadystatechange = function(event){
			if (this.readyState === XMLHttpRequest.DONE)
				if (this.status === 200)
					display_profile_picture.bind(that)(this.response);
		} 
		req.send();
	};

	function suppr_loader() {

	}

	function lazyload() {
		let divs = document.querySelectorAll(".to_load");
		divs.forEach((div) => {
			if (!!div)
				if (window.pageYOffset + window.innerHeight >= find_offset(div)) {
					let tmp = window.pageYOffset;
					load_photo.bind(div)();
				}
		});
	}


	function get_params_request() {
		let params = "";
		let number = document.querySelectorAll(".general-card");
		const csrf = document.querySelector("meta[name=csrf-token]");
		const range = document.querySelector("input[type=range]");
		if (!csrf || !number || !(number.length))
			return (-1);
		number = number.length - 1;
		params += "authenticity_token=" + normalize_data(csrf.content) + "&skip=" + number + "&range=" + range.value;
		return (params);
	}

	function search_new_profile() {
		const req = new XMLHttpRequest();
		let params = get_params_request();
		if (!isNaN(params))
			return;
		req.open('GET', '/user/get_profiles?' + params , true);
		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		req.onreadystatechange = function(event) {
			if (this.readyState === XMLHttpRequest.DONE)
				if (this.status === 200)
					console.log(this.response);
		}
		req.send();
	}

	function load_profile() {
		let loader = document.querySelector("#main_loader");
		if (loader)
			if (window.pageYOffset + window.innerHeight >= loader.offsetTop) {
				let tmp = window.pageYOffset;
				search_new_profile();
			}
	}

	function find_offset(elem, number = 0) {
		if (!elem)
			return (-1);
		if (elem == document.body)
		{
			return (number);
		}
		else
			return (find_offset(elem.parentNode, number + elem.offsetTop));
	}

	document.addEventListener("scroll", lazyload);
	window.addEventListener("resize", lazyload);
	window.addEventListener("orientationChange", lazyload);
	window.addEventListener('load', lazyload);

	document.addEventListener("scroll", load_profile);
	window.addEventListener("resize", load_profile);
	window.addEventListener("orientationChange", load_profile);
	window.addEventListener('load', load_profile);
})();

function value_converter(meter) {
	if (meter > 1000)
		return (meter / 1000).toString() + " km";
	else
		return (meter).toString() + " m";
}
