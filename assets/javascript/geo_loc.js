function get_position(){
    fetch('https://api.ipify.org/?format=json').then(function(response){
        debugger;
        return response.json();})
}
function set_position(){
    let data = get_position()
    fetch(`http://api.ipstack.com/${data.ip}?access_key=041536ed3399d39f267421df9619265c&format=1`).then(function(response){
        return response.json();}).then(function(myJson){
            $("input[name='user[latitude]'").val(myJson.latitude);
            $("input[name='user[longitude]'").val(myJson.longitude);
            console.log(myJson.latitude);
            console.log(myJson.longitude);
        });
    }
