class Player

  def health
    @warrior.health
  end

  def feel
    @warrior.feel
  end

  def rescue!
    @warrior.rescue!
  end

  def attack!
    @warrior.attack!
  end

  def walk!
    @warrior.walk!
  end

  def rest!
    @warrior.rest!
  end

  def hurt?
    return false unless @last_health
    return health < @last_health
  end

  def play_turn(warrior)
    @warrior = warrior
    if feel.captive?
      rescue!
    elsif !feel.empty?
      attack!
    elsif health == 20 || hurt?
      walk!
    else
      rest!
    end
    @last_health = health
  end

end
