module ShowHelper

    def checkbox_methode(value:, user: )
        if (user.is_related_with(id: value.id, type_of_link: 'APPRECIATE'))
            checked = 'checked'
        else
            checked = ''
        end
        h(value.id.to_s + '" name="' + value.name + '"' + checked )
    end

end