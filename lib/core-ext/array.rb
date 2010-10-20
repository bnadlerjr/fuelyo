module ArrayExtensions
  def sum
    self.inject { |sum, v| sum + v }
  end

  def avg
    self.sum / self.size
  end
end

class Array
  include ArrayExtensions
end
