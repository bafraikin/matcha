
worker.port.onmessage = function (resp) {
	if (!resp.data || resp.data == "")
		return;
	const json = resp.data;
	switch(json.type) { 
		case "all_match":
			displayMatchReadyForChat(json.data);
			break;
		case "open_conv":
			console.log(json);
			displayNewModalChat(json);
			break;
		default:
			console.log(json);
	}
};
