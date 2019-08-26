
const display_notif = function(notif) {
	const object = JSON.parse(notif.data);
	switch (object.type) {
		case 'SOMEONE_LIKED_YOU':
			console.log("tu plais a quelqu'un petit coquin");
			create_notif_like(object);
			break;
		case 'NEW_MATCH':
			console.log("nouveau match");
			break;
		case 'NEW_MESSAGE':
			console.log("nouveau message");
			break;
		default:
			console.log("something strange happen", object.type);
	}
}

const destroy_it = function() {
	this.parentNode.removeChild(this);
}

const create_notif_like = function(notif) {
	const wrapper = document.querySelector("#notif_wrapper");
	const like_span = document.querySelector("#matcha_like span");
	let number = parseInt(like_span.innerText);
	if (!isNaN(number) && number <= 98)
		like_span.innerText = ++number;
	like_span.parentNode.classList.add("active");
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
	body.classList.add("badge");
	body.classList.add("badge-info");
	body.innerHTML = notif.type.replace(/_/g, " ");
	tell_this_notif_what_should_remove_it(body);
	return (body);
}


window.onload = () => {
	document.querySelector("#matcha_like").onclick = function() {
		this.classList.remove("active");}
	document.querySelector("#matcha_match").onclick = function() {
		this.classList.remove("active");}
};
