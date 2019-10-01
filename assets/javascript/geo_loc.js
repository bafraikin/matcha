let bool = false;
function bool_true(){
    bool = true;
}

function set_ip() {
    fetch('https://api.ipify.org/?format=json').then(function (response) {
        response.json().then((data) => {
            set_position(data);
        });
    });
};


function set_position(data) {
    fetch(`http://api.ipstack.com/${data.ip}?access_key=041536ed3399d39f267421df9619265c&format=1`).then(function (response) {
        response.json().then(function (myJson) {
            $("input[name='user[latitude]'").val(myJson.latitude);
            $("input[name='user[longitude]'").val(myJson.longitude);
        })
    })
};

function initMap() {
    let latitude = document.querySelector("div#latitude");
    let longitude = document.querySelector("div#longitude");
    
    let myLatLng = { lat: parseFloat(latitude.attributes.name.nodeValue), lng: parseFloat(longitude.attributes.name.nodeValue) };

    let map = new google.maps.Map(document.getElementById('map'), {
        zoom: 8,
        disableDefaultUI : true,
        center: myLatLng,
        mapTypeId: 'terrain' 
    });

    let marker = new google.maps.Marker({
        position: myLatLng,
        map: map,
        draggable: bool,
        title: 'User',
    });
    if (bool)
        marker.addListener('dragend', function() {
         let csrf = document.querySelector("meta[name=csrf-token]");
	    	if (!csrf)
    			return;
    		csrf = csrf.content;
    		const req = new XMLHttpRequest();
    		req.open('POST', '/user/geo_update', true);
    		req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    		req.setRequestHeader("HTTP_X_CSRF_TOKEN", csrf);
    		req.onreadystatechange = function (event) {
    			if (this.readyState === XMLHttpRequest.DONE) {
	    			if (this.status === 200 && this.response.match(/true/))
		    			alert("Votre localisation a bien était changer 🇫🇷");
		    	}
		    };
	    	req.send("longitude=" + encodeURI(marker.getPosition().lng()) + "&latitude=" + encodeURI(marker.getPosition().lat()) + "&authenticity_token=" + normalize_data(csrf));
        });    
}