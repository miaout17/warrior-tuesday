module Strategy

  class Undirectional < Base
    def evaluate
      if should_action?
        take_action!
        true
      else
        false
      end
    end
  end

  class RestWhenTicking < Undirectional
    def should_action?
      return false unless warrior.listen.any?(&:ticking?)
      return false if !player.detonated? || player.enemy_eliminated?
      if neighbor_enemies.empty?
        warrior.health < 16
      else
        false
      end
    end
    def take_action!
      warrior.rest!
    end
  end

  class Rest < Undirectional
    def should_action?
      health = warrior.health
      if health>=20 || player.enemy_eliminated?
        false
      elsif health>=12 && (player.possible_enemy_count==1||warrior.listen.count(&:enemy?)==0)
        false
      else
        true
      end
    end
    def take_action!
      warrior.rest!
    end
  end

  class WalkToStairs < Undirectional
    def should_action?
      true
    end
    def take_action!
      player.walk!(warrior.direction_of_stairs)
    end
  end

end
