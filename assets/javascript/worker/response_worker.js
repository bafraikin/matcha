
worker.port.onmessage = function (resp) {
	if (resp.data == "")
		return;
	const json = JSON.parse(resp.data);
	switch(json.type) { 
		case "all_match":
			displayMatchReadyForChat(json.data);
			break;
		default:
			console.log(json.type);
	}
};
