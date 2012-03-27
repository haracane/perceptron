module Perceptron
  module IdVector
    def self.product(vector1, vector2)
      n = [vector1.size, vector2.size].max
      ret = 0
      n.times do |i|
        ret += (vector1[i] || 0) * (vector2[i] || 0)
      end
      return ret
    end
    
    def self.add_vector(a, vector1, b, vector2)
      n = [vector1.size, vector2.size].max
      ret = 0
      n.times do |i|
        vector1[i] = a * (vector1[i] || 0) + b * (vector2[i] || 0)
      end
    end
  end
end