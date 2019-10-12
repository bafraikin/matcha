
worker.port.onmessage = function (resp) {
	if (!resp.data || resp.data == "")
		return;
	const json = resp.data;
	switch(json.type) { 
		case "all_match":
			displayMatchReadyForChat(json.data);
			break;
		case "open_conv":
			displayNewModalChat(json);
			break;
		case "NEW_MATCH":
			display_notif(json);
			break;
		case "SOMEONE_LIKED_YOU":
			display_notif(json);
			break;
		default:
			console.log(json);
	}
};
