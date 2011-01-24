module Strategy

  class PathFind < Base
    def walk_to_items!(items)
      return false if items.empty?

      # This makes directions of items has higher priority
      dirs = items.map { |item| warrior.direction_of(item) }
      dirs.uniq!

      DIRS.each { |dir| dirs << dir unless dirs.include?(dir) }
      
      dirs = dirs.
        select { |dir| warrior.feel(dir).empty? }.
        select { |dir| !warrior.feel(dir).stairs? }.
        select { |dir| dir!=player.last_dir }
      
      if dirs.empty?
        false
      else
        player.walk!(dirs.first) 
        true
      end
    end
  end

  class WalkToSounds < PathFind
    def evaluate
      walk_to_items!(warrior.listen)
    end
  end

  class WalkToTicking < PathFind
    def evaluate
      bombs = warrior.listen.select(&:ticking?)
      walk_to_items!(bombs)
    end
  end

end
