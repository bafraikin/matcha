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

	def check_if_valide_hashtag_and_return_id(value)
		id_hashtag = Hashtag.where(equality: {name: params[:value]})[0].id
		return id_hashtag if id_hashtag.is_a? Integer
		false
	end 

	def check_if_valide_gender?(value)
		return true if User.gender_pool.include?(value)
		false
	end

	def looking_for_gender(gender:)
		checked = ''
		if (current_user.interest.include? gender)
			checked = 'checked'
		end
		'value=' + gender + ' ' + checked
	end
end
