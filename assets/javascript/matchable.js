
function normalize_data(data) {
	return (data.replace(/\+/g, '%2B'));
}

function send_like(id)
{
	const req = new XMLHttpRequest();
	const csrf = document.querySelector("meta[name=csrf-token]").content
	if (isNaN(id) && !!csrf)
		return;
	req.open('POST', '/user/add_like', true);
	req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);

	req.onreadystatechange = function(event) 
	{
		if (this.readyState === XMLHttpRequest.DONE)
		{
			if (this.status === 200) 
				console.log("Réponse recu", this);
			else 
				console.log("Status de la réponse: %d (%s)", this.status, this.statusText);
		}
	}
	req.send("id=" + id + "&authenticity_token=" + normalize_data(csrf));

}



