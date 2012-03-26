require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Perceptron" do
  it "should work" do
    inputs = []
    inputs.push [0, "Humpty Dumpty sat on a wall"]
    inputs.push [0, "Humpty Dumpty had a great fall"]
    inputs.push [1, "All the king's horses and all the king's men"]
    inputs.push [1, "Could n't put Humpty together again"]
    
    perceptron = Perceptron.new(2)
    
    inputs.each do |input|
      perceptron.add_correct_text(input[0], input[1])
    end
    
    STDERR.puts "initial weight vector list is #{perceptron.weight_vector_list.inspect}"
    perceptron.train_loop
    tests = ["Humpty Dumpty hit a wall", "Humpty Dumpty put All horses together"]
    tests.each do |test|
      STDERR.puts "classify #{test.inspect}"
      STDERR.puts "  -> #{perceptron.classify_text(test)}"
      STDERR.puts "  -> #{perceptron.classify_text_average(test)}(average)"
    end
    
  end
end
