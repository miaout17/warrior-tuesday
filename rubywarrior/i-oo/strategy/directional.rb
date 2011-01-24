module Strategy

  class Directional < Base
    def evaluate
      DIRS.each do |dir|
        if should_action?(dir)
          take_action!(dir)
          return true
        end
      end
      false
    end
  end

  class RescueTicking < Directional
    def should_action?(dir)
      warrior.feel(dir).ticking?
    end
    def take_action!(dir)
      warrior.rescue!(dir)
    end
  end

  class RescueCaptive < Directional
    def should_action?(dir)
      warrior.feel(dir).captive?
    end
    def take_action!(dir)
      warrior.rescue!(dir)
    end
  end

  class Attack < Directional
    def should_action?(dir)
      warrior.feel(dir).enemy?
    end
    def take_action!(dir)
      warrior.attack!(dir)
    end
  end

  class AttackMemorizedEnemy < Directional
    def should_action?(dir)
      player.remember_enemy?(dir)
    end
    def take_action!(dir)
      warrior.attack!(dir)
    end
  end

  class Detonate < Directional
    def should_action?(dir)
      bombs = warrior.listen.select(&:ticking?)
      if bombs.any? { |b| warrior.distance_of(b)<=2 }
        false #bombs are too near to detonate
      elsif warrior.look(dir).first(2).all?(&:enemy?)
        true
      else
        false
      end
    end
    def take_action!(dir)
      player.detonate!(dir)
    end
  end

end
