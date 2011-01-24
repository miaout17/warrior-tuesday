class Player

  def hurt?
    return false unless @last_health
    return @warrior.health < @last_health
  end

  def play_turn(warrior)
    @warrior = warrior
    if @warrior.feel.captive?
      @warrior.rescue!
    elsif !@warrior.feel.empty?
      @warrior.attack!
    elsif @warrior.health == 20 || hurt?
      @warrior.walk!
    else
      @warrior.rest!
    end
    @last_health = @warrior.health
  end

end
