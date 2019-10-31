
const display_notif = function(notif) {
	switch (notif.type) {
		case 'SOMEONE_LIKED_YOU':
			display_this_notif(notif);
			break;
		case 'NEW_MATCH':
			notif_match(notif);
			break;
		case 'ERROR':
			notif_error(notif);
			break;
		case 'NEW_MESSAGE':
			display_this_notif(notif);
			break;
		case 'SOMEONE_HAS_SAW_YOUR_PROFILE':
			display_this_notif(notif);
			break;
		default:
			console.log("something strange happen", notif);
	}
}

	function normalize_data(data) {
		return (data.replace(/\+/g, '%2B'));
	}

const destroy_it = function() {
	this.parentNode.removeChild(this);
}

const notif_match = function(notif) {
	const wrapper = document.querySelector("#notif_wrapper");
	notif = create_notif(notif);
	if (!(notif && wrapper))
		return;
	if (window.innerWidth < 600)
	{
		notif.classList.add("alert");
		notif.classList.add("alert-warning");
	}
	else
	{
		notif.classList.add("badge");
		notif.classList.add("badge-warning");
	}
	wrapper.append(notif);
}

const notif_error = function(notif) {
	const wrapper = document.querySelector("#notif_wrapper");
	notif = create_notif(notif);
	if (!(notif && wrapper))
		return;
	notif.classList = "";
	if (window.innerWidth < 600)
	{
		notif.classList.add("alert");
		notif.classList.add("alert-danger");
	}
	else
	{
		notif.classList.add("badge");
		notif.classList.add("badge-danger");
	}
	wrapper.append(notif);
}


const display_this_notif = function(notif) {
	const wrapper = document.querySelector("#notif_wrapper");
	notif = create_notif(notif);
	wrapper.append(notif);
}

const tell_this_notif_what_should_remove_it = function(notif) {
	notif.addEventListener("remove", destroy_it, {once: true});
	let timer = setTimeout(function(notif) {notif.dispatchEvent(new Event("remove"))}, 3000, notif);
	notif.addEventListener("click", function(notif) {
		notif.dispatchEvent(new Event("remove"));
	}.bind(this, notif));
}

const create_notif = function(notif) {
	const body = document.createElement("p");
	if (window.innerWidth < 600)
	{
		body.classList.add("alert");
		body.classList.add("alert-primary");
	}
	else
	{
		body.classList.add("badge");
		body.classList.add("badge-info");
	}
	body.innerHTML = notif.type.replace(/_/g, " ");
	tell_this_notif_what_should_remove_it(body);
	return (body);
}

window.onload = () => {
	let like = document.querySelector("#matcha_like");
	let match = document.querySelector("#matcha_match");
	if (like)
		like.onclick = function() {this.classList.remove("active");}
	if (match)
		match.onclick = function() {this.classList.remove("active");}
};
