module Perceptron
  class IdVectorManager
    attr_reader :word_list, :word_hash
    def initialize(init_vector=[])
      @word_hash = {}
      @word_list = []
      @init_vector = init_vector.clone
    end
    
    def vector_to_s(vector)
      ret = []
      (@init_vector.size).upto(vector.size-1).each do |wid|
        next if vector[wid] == 0
        ret.push @word_list[wid]
      end
      return ret.inspect
    end
    
    def vector_from_text(text)
      self.vector_from_words(text.split(/\s+/))
    end
    
    def vector_from_words(words)
      self.vector_from_ids(self.ids_from_words(words))
    end
    
    def vector_from_ids(id_list)
      # ret = Array.new(self.max_id, 0)
      # ret[0] = 1
      ret = @init_vector.clone
      id_list.each do |i|
        ret[i] = (ret[i] || 0) + 1
      end
      return ret
    end
    
    def ids_from_words(words)
      return words.map {|w| self.id_from_word(w)}
    end
    
    def id_from_word(word)
      id = @word_hash[word]
      if id.nil? then
        @word_hash[word] = self.max_id + 1
        id = self.max_id
        @word_list[id] = word
      end
      return id
    end
    
    def word_from_id(id)
      return @word_list[id]
    end
    
    def max_id
      return @word_hash.size + @init_vector.size - 1
    end
    
    def words_size
      return @word_hash.size
    end
  end
end