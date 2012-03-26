class Perceptron
  attr_reader :word_hash, :weight_vector_list, :correct_vectors_list
  def initialize(class_size)
    @word_hash = {}
    @word_list = []
    @weight_vector_list = Array.new(class_size)
    @weight_vector_list.map!{|v| [1]}
    @correct_vectors_list = Array.new(class_size)
    @correct_vectors_list.map!{|v| []}
    @averaged_weight_vector_list = Array.new(class_size)
    @averaged_weight_vector_list.map!{|v| [1]}
    @update_vector_list = Array.new(class_size)
    @update_vector_list.map!{|v| []}
    @train_count = 0
  end
  
  def class_size
    return @weight_vector_list.size
  end
  
  def product(vector1, vector2)
    n = [vector1.size, vector2.size].max
    ret = 0
    n.times do |i|
      ret += (vector1[i] || 0) * (vector2[i] || 0)
    end
    return ret
  end
  
  def add_vector(a, vector1, b, vector2)
    n = [vector1.size, vector2.size].max
    ret = 0
    n.times do |i|
      vector1[i] = a * (vector1[i] || 0) + b * (vector2[i] || 0)
    end
  end
  
  def train_loop(n=10)
    STDERR.puts :train_loop
    n.times do |i|
      fail_count = self.train
      STDERR.puts "weight vector list is #{@weight_vector_list.inspect}"
      break if fail_count == 0
    end
  end
  
  def train
    fail_count = 0
    @train_count += 1
    self.class_size.times do |class_id|
      vectors = @correct_vectors_list[class_id]
      vectors.each do |vector|
        result = self.classify_vector(vector, @weight_vector_list)
        if result != class_id then
          fail_count += 1
          STDERR.puts "failed to classify #{vector.inspect}: result is #{result} but should be #{class_id}"
          self.add_vector(1, @weight_vector_list[class_id], 1, vector)
          self.add_vector(1, @weight_vector_list[result], -1, vector)
          self.add_vector(1, @update_vector_list[class_id], @train_count, vector)
          self.add_vector(1, @update_vector_list[result], -@train_count, vector)
        end
      end
    end
    
    self.class_size.times do |class_id|
      awv = @averaged_weight_vector_list[class_id]
      wv = @weight_vector_list[class_id]
      uv = @update_vector_list[class_id]
      n = [awv.size, awv.size, uv.size].max

      n.times do |i|
        awv[i] = (wv[i]||0) - (uv[i]||0) / (@train_count + 1)
      end
    end
    return fail_count
  end
  
  def classify_text(text)
    self.classify_vector(self.vector_from_text(text), @weight_vector_list)
  end
  
  def classify_text_average(text)
    self.classify_vector(self.vector_from_text(text), @averaged_weight_vector_list)
  end
  
  def classify_vector(vector, weight_vectors)
    # STDERR.puts "classify_vector(#{vector.inspect})"
    ret = nil
    max_score = nil
    
    self.class_size.times do |class_id|
      # STDERR.puts "check class #{class_id}"
      weight_vector = weight_vectors[class_id]
      score = self.product(weight_vector, vector)
      if max_score.nil? || max_score < score then
        ret = class_id
        max_score = score
      end
    end
    # STDERR.puts "returns #{ret}"
    return ret
  end
  
  def add_correct_text(class_id, text)
    # STDERR.puts "add_correct_text(#{class_id}, #{text.inspect})"
    vector = self.vector_from_text(text)
    # STDERR.puts "add vector #{vector.inspect}"
    @correct_vectors_list[class_id].push vector
    # STDERR.puts "correct vectors list is #{@correct_vectors_list.inspect}"
  end
  
  def vector_from_text(text)
    self.vector_from_wids(self.wids_from_text(text))
  end
  
  def vector_from_wids(wid_list)
    ret = Array.new(self.max_wid, 0)
    ret[0] = 1
    wid_list.each do |i|
      ret[i] = (ret[i] || 0) + 1
    end
    return ret
  end
  
  def wids_from_text(text)
    return text.split(/\s+/).map {|w| self.wid_from_word(w)}
  end
  
  def wid_from_word(word)
    wid = @word_hash[word]
    if wid.nil? then
      @word_hash[word] = self.max_wid + 1
      wid = max_wid
      @word_list[wid] = word
    end
    return wid
  end
  
  def max_wid
    return @word_hash.size
  end
  
end