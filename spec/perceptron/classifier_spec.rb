require 'spec_helper'

describe Perceptron::Classifier do
  it "should cassify" do
    inputs = []
    inputs.push [:like, "Humpty Dumpty sat on a wall"]
    inputs.push [:like, "Humpty Dumpty had a great fall"]
    inputs.push [:dislike, "All the king's horses and all the king's men"]
    inputs.push [:dislike, "Could n't put Humpty together again"]
    
    perceptron = Perceptron::Classifier.new
    
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
  
  it "should attach tags" do
    perceptron = Perceptron::Classifier.new
    perceptron.add_correct_tagged_text("Paul/NNP Krugman/NNP ,/, a/DT professor/NN at/IN Princeton/NNP University/NNP ,/, was/VBD awarded/VBN the/DT Nobel/NNP Prize/NNP in/IN Economics/NNP on/IN Monday/NNP ./.")
    perceptron.add_correct_tagged_text("Estimated/VBN volume/NN was/VBD a/DT light/JJ 2.4/CD million/CD ounces/NNS ./.")
    perceptron.train_loop
  end
end
