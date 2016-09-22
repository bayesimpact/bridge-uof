# Monkey-patches to the String class go here.
class String
  # http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
  def integer?
    to_i.to_s == self
  end

  # Convert the string to an integer only if it is actually an integer, return nil otherwise.
  def to_i_safe
    integer? ? to_i : nil
  end

  # Like #humanize but handles *_id strings better.
  def custom_humanize
    end_with?('_id') ? (humanize + " ID") : humanize
  end
end
