module GeolocalisationHelper
    def save_if_valide_coordinate(latitude, longitude)
        latitude = latitude.to_f
        longitude = longitude.to_f
        return "geolocalisation error" if (latitude == 0 || longitude == 0)
        current_user.latitude = latitude
        current_user.longitude = longitude
        current_user.save
        true.to_json
    end
end