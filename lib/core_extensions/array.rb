# Monkey-patches to the Array class go here.
class Array
  # (Used in FactoryGirl factories.)
  # Usually samples a single element from an array, but sometimes samples two.
  def sample_one_or_two_elements
    sample(rand(5).zero? ? 2 : 1)
  end

  # (Used in tests.)
  # Check if an array is sorted.
  def sorted?
    self == sort
  end
end
