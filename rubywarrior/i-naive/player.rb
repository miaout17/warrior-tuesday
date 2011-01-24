#BAD SAMPLE!! DON'T LEARN

class Player

  DIRS = [:forward, :left, :backward, :right]
  OFFSETS = {
    :forward => [1, 0], 
    :backward => [-1, 0], 
    :left => [0, -1], 
    :right => [0, 1]
  }

  def walk!(dir=nil)
    @pos = pos(dir)
    @last_dir = reverse_dir(dir)
    @warrior.walk!(dir)
  end

  def detonate!(dir=nil)
    @detonated = true
    @warrior.detonate!(dir)
  end

  def play_turn(warrior)
    @warrior = warrior

    unless @initialized
      @pos = [0, 0]
      @enemies = []
      @possible_enemy_count = @warrior.listen.count {|o| o.enemy?}
      @initialized = true
    end

    memorize_enemies
    
    perform_action

    @lath_health = @warrior.health
  end

  def perform_action

    DIRS.each do |dir|
      if @warrior.feel(dir).ticking?
        @warrior.rescue!(dir)
        return
      end
    end

    if rest_when_ticking?
      @warrior.rest!
      return
    end

    return if walk_to_ticking!
    return if try_bind!

    DIRS.each do |dir|
      if should_detonate?(dir)
        detonate!(dir)
        return
      end
    end

    DIRS.each do |dir|
      if @warrior.feel(dir).enemy?
        @warrior.attack!(dir)
        return
      end
    end

    if should_rest?
      @warrior.rest!
      return
    end

    DIRS.each do |dir|
      if @enemies.include?(pos(dir))
        @warrior.attack!(dir)
        return
      end
    end

    DIRS.each do |dir|
      if @warrior.feel(dir).captive?
        @warrior.rescue!(dir)
        return
      end
    end

    unless walk_to_sounds!
      walk_to_stairs!
    end

  end

  def memorize_enemies
    DIRS.each do |dir|
      target_pos = pos(dir)
      if @warrior.feel(dir).enemy?
        @enemies << target_pos unless @enemies.include?(target_pos)
      elsif @warrior.feel(dir).empty? and @enemies.include?(target_pos)
        @enemies.delete(target_pos)
        @possible_enemy_count -= 1
        @last_dir = nil
      end
    end
  end

  def should_rest?
    if @warrior.health>=20 || enemy_eliminated?
      false
    elsif @warrior.health>=12 && (@possible_enemy_count==1||@warrior.listen.count(&:enemy?)==0)
      false
    else
      true
    end
  end

  def pos(dir=nil)
    offset = dir ? OFFSETS[dir] : [0, 0]
    [@pos[0]+offset[0], @pos[1]+offset[1]]
  end

  def walk_to_items!(items)
    return if items.empty?

    # This makes directions of items has higher priority
    dirs = items.map { |item| @warrior.direction_of(item) }
    dirs.uniq!

    DIRS.each { |dir| dirs << dir unless dirs.include?(dir) }
    
    dirs = dirs.
      select { |dir| @warrior.feel(dir).empty? }.
      select { |dir| !@warrior.feel(dir).stairs? }.
      select { |dir| dir!=@last_dir }

    walk!(dirs.first) unless dirs.empty?
  end

  def rest_when_ticking?
    return false unless @warrior.listen.any?(&:ticking?)
    return false if !@detonated || enemy_eliminated?
    if neighbor_enemies.empty?
      @warrior.health < 16
    else
      false
    end
  end
  
  def should_detonate?(dir)
    bombs = @warrior.listen.select(&:ticking?)
    if bombs.any? { |b| @warrior.distance_of(b)<=2 }
      false #bombs are too near to detonate
    else
      @warrior.look(dir).first(2).all?(&:enemy?)
    end
  end

  def walk_to_ticking!
    bombs = @warrior.listen.select(&:ticking?)
    walk_to_items!(bombs)
  end

  def walk_to_sounds!
    walk_to_items!(@warrior.listen)
  end

  def walk_to_stairs!
    walk!(@warrior.direction_of_stairs)
  end

  def try_bind!
    enemies = neighbor_enemies
    if enemies.count > 1
      @warrior.bind!(enemies.last)
    end
  end

  def neighbor_enemies
    DIRS.select { |dir| @warrior.feel(dir).enemy? }
  end

  # Is enemy possible exist?
  def enemy_eliminated?
    items = @warrior.listen

    if items.empty? 
      true
    elsif items.all?(&:ticking?)
      true
    elsif @possible_enemy_count==0
      true
    else
      false
    end
  end

  def reverse_dir(dir)
    index = DIRS.index(dir)
    rev_index = (index+2) % 4
    DIRS[rev_index]
  end

end
