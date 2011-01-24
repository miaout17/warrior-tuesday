class Warrior
  attr_accessor :health
end

w = Warrior.new
w.health = 95
puts w.health

class Warrior
  def health
    @health
  end
  def health=(val)
    @health = val
  end
end

w = Warrior.new
w.health = 59
puts w.health