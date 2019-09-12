
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

	function display_photo(object) {
		const div = document.getElementById('photo');
		for (img of object) {
			add_photo(div, img);
		}
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

	function add_photo(sidebar, img) {
		sidebar.append(construct_photo(img));
	}

	function suppr_loader() {

	}

	function lazyload() {
		lazyloadThrottleTimeout = setTimeout(function () {
			let divs = document.querySelectorAll(".to_load");
			divs.forEach((div) => {
				if (!!div)
					if (window.pageYOffset + window.innerHeight >= document.body.clientHeight - div.offsetHeight) {
						let tmp = window.pageYOffset;
						load_photo.bind(div)();
						/*
						.then(function (responseText) {
							let response = JSON.parse(responseText);
							if (!Array.isArray(response) && !!response.match(/^done$/))
								suppr_loader();
							else {
								display_photo(JSON.parse(responseText));
								window.scroll(0, tmp);
								lazyload();
							}
						});*/
					}
			});
		}, 1500)
	};



	document.addEventListener("scroll", lazyload);
	window.addEventListener("resize", lazyload);
	window.addEventListener("orientationChange", lazyload);
	window.addEventListener('load', lazyload);
	//  window.addEventListener('load', load_photo);
})();

function value_converter(meter) {
	if (meter > 1000)
		return (meter / 1000).toString() + " km";
	else
		return (meter).toString() + " m";
}



