class Hashtag < MatchaBase
  attr_accessor :name, :id

  def self.possible_hashtag
    ['#ruby', '#node', '#NO', '#YES', '#travel', '#hiking', '#hashtag', '#DOG', '#CAT', '#wine']
  end

  def self.labels
    []
  end

  def self.cant_be_blank_on_creation
		[:name]
	end

  def self.create
    array = possible_hashtag
    array.each do  |hashtag| 
      hash = {name: hashtag}
      super(hash: hash)
    end
  end
end
