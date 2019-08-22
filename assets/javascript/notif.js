
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

const create_notif_like = function(notif) {
	notif = create_notif(notif);
	
}

const create_notif = function(notif) {
	const body = document.createElement("p");
	body.innerHTML = notif.type(/_/g, " ");
	return (body);
}

