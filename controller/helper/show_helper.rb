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

end