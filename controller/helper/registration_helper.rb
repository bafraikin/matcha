module RegistrationHelper
    def save_if_valide_coordinate(latitude, longitude)
        latitude = latitude.to_i
        longitude = longitude.to_i
        return if (latitude == 0 || longitude == 0)
        current_user.latitude == latitude
        current_user.longitude == longitude
        current_user.save
    end
end