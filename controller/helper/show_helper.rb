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

    def check_if_valide_hashtag?(value)
        Hashtag.all.each do |hashtag|
            return true if (hashtag.name == params[:value])
end      
        return false
    end 
end