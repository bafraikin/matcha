module ShowHelper

    def checkbox_methode(hashtag:, checkbox: )
        checked = ''
        if (checkbox.include?(hashtag.name))
            checked = 'checked'
        end
        'value=' + hashtag.name + ' ' + checked
    end

    def showoff_hashtag(hashtag:, checkbox: )
        if (checkbox.include?(hashtag.name))
            hashtag.name
        end
    end

    def check_if_valide_hashtag(value)
        id_hashtag = Hashtag.where(equality: {name: params[:value]})[0].id
        return id_hashtag if id_hashtag.is_a? Integer
         false
    end 
end