
	const display_profile_picture = function (response) {
		this.querySelector("img").src = "/assets/pictures/" + JSON.parse(response)
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

