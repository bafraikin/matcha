
(function () {
	function normalize_data(data) {
		return (data.replace(/\+/g, '%2B'));
	}

	function construct_photo(name) {
		let href = "/galerie/photo/" + name;
		let div = document.createElement('div');
		div.classList.add('photo_loaded');
		let string = "<a href='/galerie/photo.php?img=" + name + "'><img src='" + href + "'/></a>";
		div.innerHTML = string;
		return (div);
	}

	function display_photo(object) {
		const div = document.getElementById('photo');
		for (img of object) {
			add_photo(div, img);
		}
	}

	function load_photos() {
		return new Promise((resolve, reject) => {
			const req = new XMLHttpRequest();
			const csrf = document.querySelector("meta[name=csrf-token]").content
			let string = "skip=" + document.querySelectorAll('div.general-card').length;
			string += "&json=1&number=15";
			req.open('GET', '/user/matchable', true);
			req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			req.onload = () => resolve(req.responseText);
			req.onerror = () => reject(req.statusText);
			req.send(string);
		});
	}

	function add_photo(sidebar, img) {
		sidebar.append(construct_photo(img));
	}

	function suppr_loader() {

	}

	function lazyload() {
		lazyloadThrottleTimeout = setTimeout(function () {
			let div = document.querySelector(".to_load");
			if (!!div)
				if (window.pageYOffset + window.innerHeight >= document.body.clientHeight - div.offsetHeight) {
					let tmp = window.pageYOffset;
					load_photo().then(function (responseText) {
						let response = JSON.parse(responseText);
						if (!Array.isArray(response) && !!response.match(/^done$/))
							suppr_loader();
						else {
							display_photo(JSON.parse(responseText));
							window.scroll(0, tmp);
							lazyload();
						}
					});
				}
		}, 1500)
	};


	document.addEventListener("scroll", lazyload);
	window.addEventListener("resize", lazyload);
	window.addEventListener("orientationChange", lazyload);

	window.addEventListener('load', lazyload);
	window.addEventListener('load', load_photo);
})();



