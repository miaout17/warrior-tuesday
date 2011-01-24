require 'forwardable'

class Player

  extend Forwardable

  def_delegators :@warrior, :health, :feel, :rescue!, :attack!, :walk!, :rest!

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
