module GeolocalisationHelper
    def save_if_valide_coordinate(latitude, longitude)
        latitude = latitude.to_f
        longitude = longitude.to_f
        if (latitude == 0 || longitude == 0)
            latitude = 48.9026985168457
            longitude = 2.304080009460449
        end
        current_user.latitude = latitude
        current_user.longitude = longitude
        current_user.save
        true.to_json
    end
end