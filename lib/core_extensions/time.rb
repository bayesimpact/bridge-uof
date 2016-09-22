# Monkey-patches to the Time class go here.
class Time
  def self.this_year
    current.year
  end

  def self.last_year
    this_year - 1
  end
end
