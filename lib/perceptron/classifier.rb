class Perceptron::Classifier
  attr_reader :word_hash, :weight_vector_list, :correct_vectors_list
  def initialize
    @word_vector_manager = Perceptron::IdVectorManager.new([1])
    @class_vector_manager = Perceptron::IdVectorManager.new
    @weight_vector_list = []
    @correct_vectors_list = []
    @averaged_weight_vector_list = []
    @update_vector_list = []
    @train_count = 0
  end
  
  def class_size
    return @class_vector_manager.words_size
  end
  
  def train_loop(n=10)
    return if n == 0
    STDERR.puts "Perceptron.train_loop(#{n})"
    fail_count = self.train
#    STDERR.puts "(INFO) weight vector list is #{@weight_vector_list.inspect}"
    if fail_count == 0 then
      STDERR.puts "(INFO) no failure. finish loop"
    else
      self.train_loop(n-1)
    end
  end
  
  def train
    success_count = 0
    fail_count = 0
    @train_count += 1
    self.class_size.times do |class_id|
      vectors = @correct_vectors_list[class_id]
      # STDERR.puts class_id
      # STDERR.puts vectors.inspect
      vectors.each do |vector|
        result = self.classify_vector(vector, @weight_vector_list)
        if result == class_id then
          success_count += 1
        else
          fail_count += 1
          STDERR.puts "failed to classify #{@word_vector_manager.vector_to_s(vector)}: result is #{@class_vector_manager.word_list[result]} but should be #{@class_vector_manager.word_list[class_id]}"
          Perceptron::IdVector.add_vector(1, @weight_vector_list[class_id], 1, vector)
          Perceptron::IdVector.add_vector(1, @weight_vector_list[result], -1, vector)
          Perceptron::IdVector.add_vector(1, @update_vector_list[class_id], @train_count, vector)
          Perceptron::IdVector.add_vector(1, @update_vector_list[result], -@train_count, vector)
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
    STDERR.puts "(INFO) finished training: #{success_count} success, #{fail_count} failures"
    return fail_count
  end
  
  def classify_text(text)
    cid = self.classify_vector(@word_vector_manager.vector_from_text(text), @weight_vector_list)
    return @class_vector_manager.word_from_id(cid)
  end
  
  def classify_text_average(text)
    cid = self.classify_vector(@word_vector_manager.vector_from_text(text), @averaged_weight_vector_list)
    return @class_vector_manager.word_from_id(cid)
  end
  
  def classify_vector(vector, weight_vectors)
    # STDERR.puts "classify_vector(#{vector.inspect})"
    ret = nil
    max_score = nil
    
    self.class_size.times do |class_id|
      # STDERR.puts "check class #{class_id}"
      weight_vector = weight_vectors[class_id]
      score = Perceptron::IdVector.product(weight_vector, vector)
      if max_score.nil? || max_score < score then
        ret = class_id
        max_score = score
      end
    end
    # STDERR.puts "returns #{ret}"
    return ret
  end
  
  def add_correct_tagged_text(tagged_text)
    wordinfo_list = tagged_text.split(/\s+/).map{|t|t.split(/\//)}
    wordinfo_list.size.times do |wi|
      prev_record = nil
      next_record = nil
      prev_record = wordinfo_list[wi-1] if 0 < wi
      next_record = wordinfo_list[wi+1]
      record = wordinfo_list[wi]
      # STDERR.puts record.inspect
      word = record[0]
      classname = record[1]
      
      features = []
      features.push "W0_#{word}"
      features.push "PREV_#{prev_record[0]}"if prev_record
      features.push "NEXT_#{next_record[0]}"if next_record
      
      wlen = word.length
      3.upto([wlen - 1, 4].min).each do |i|
        features.push "H#{i}_#{word[0..(i-1)]}"
      end
      2.upto([wlen - 1, 3].min).each do |i|
        features.push "T#{i}_#{word[(-1-i+1)..-1]}"
      end
      self.add_correct_words(classname, features)
    end
  end
  
  def add_correct_text(classname, text)
    self.add_correct_words(classname, text.split(/\s+/))
  end
  
  def add_correct_words(classname, words)
    class_id = self.cid_from_classname(classname)
    # STDERR.puts "add_correct_text(#{class_id}, #{text.inspect})"
    vector = @word_vector_manager.vector_from_words(words)
    # STDERR.puts "add vector #{vector.inspect}"
    @correct_vectors_list[class_id].push vector
    # STDERR.puts "correct vectors list is #{@correct_vectors_list.inspect}"
  end

  
  def cid_from_classname(classname)
    classname = classname.to_s
    cid = @class_vector_manager.word_hash[classname]
    if cid.nil? then
      cid = @class_vector_manager.id_from_word(classname)
      @weight_vector_list[cid] = [1]
      @correct_vectors_list[cid] = []
      @averaged_weight_vector_list[cid] = [1]
      @update_vector_list[cid] = []
    end
    return cid
  end
  
end