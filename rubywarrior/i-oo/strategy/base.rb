module Strategy
  
  class Base
    attr_reader :player

    def initialize(player)
      @player = player
    end

    def warrior
      @player.warrior
    end

    def neighbor_enemies
      DIRS.select { |dir| warrior.feel(dir).enemy? }
    end
  end

  class Bind < Base
    def evaluate
      enemies = neighbor_enemies
      if enemies.count > 1
        warrior.bind!(enemies.last)
        true
      else
        false
      end
    end
  end

end
