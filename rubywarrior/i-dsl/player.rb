require 'player_helper'

class Player

  include PlayerHelper

  actions :walk!, :attack!, :rest!, :bind!, :rescue!, :detonate!
  senses :feel, :direction_of_stairs, :health, :listen, :direction_of, :look, :distance_of

  # The following statement is equivalent: 
  # strategy(:rest!, :should_rest?)
  # strategy(:rest!) { should_rest? }
  # strategy { rest! if should_rest? }

  # The following statement is equivalent: 
  # directional(:attack!, :enemy?)
  # directional(:attack!) { |d| enemy?(d) }
  # directional { |d| attack!(d) if enemy?(d) }

  def_strategries do
    directional(:rescue!, :ticking?)
    strategy { rest! if rest_when_ticking? }
    strategy { walk_to_items!(listen.select(&:ticking?)) }
    strategy { bind!(nearby_enemies.last) if nearby_enemies.count>1 }
    directional(:detonate!, :should_detonate?)
    directional(:attack!, :enemy?)
    strategy(:rest!, :should_rest?)
    directional { |dir| attack!(dir) if @enemies.include?(pos(dir)) }
    directional(:rescue!, :captive?)
    strategy { walk_to_items!(listen) }
    strategy { walk!(direction_of_stairs) }
  end

  on_start do
    @pos = [0, 0]
    @enemies = []
    @possible_enemy_count = listen.count {|o| o.enemy?}
  end

  before(:play_turn) { memorize_enemies }

  after(:play_turn) { @last_health = health }

  before(:walk!) do |dir|
    @pos = pos(dir)
    @last_dir = reverse_dir(dir)
  end

  before(:detonate!) { |dir| @detonated = true }

  def memorize_enemies
    DIRS.each do |dir|
      target_pos = pos(dir)
      if enemy?(dir)
        @enemies << target_pos unless @enemies.include?(target_pos)
      elsif empty?(dir) and @enemies.include?(target_pos)
        @enemies.delete(target_pos)
        @possible_enemy_count -= 1
        @last_dir = nil
      end
    end
  end

  def should_rest?
    if health>=20 || enemy_eliminated?
      false
    elsif health>=12 && (@possible_enemy_count==1||listen.count(&:enemy?)==0)
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
    dirs = items.map { |item| direction_of(item) }
    dirs.uniq!

    DIRS.each { |dir| dirs << dir unless dirs.include?(dir) }
    
    dirs = dirs.
      select { |dir| empty?(dir) }.
      select { |dir| !stairs?(dir) }.
      select { |dir| dir!=@last_dir }

    walk!(dirs.first) unless dirs.empty?
  end

  def rest_when_ticking?
    return false unless listen.any?(&:ticking?)
    return false if !@detonated || enemy_eliminated?
    if nearby_enemies.empty?
      health < 16
    else
      false
    end
  end
  
  def should_detonate?(dir)
    bombs = listen.select(&:ticking?)
    if bombs.any? { |b| distance_of(b)<=2 }
      false #bombs are too near to detonate
    else
      look(dir).first(2).all?(&:enemy?)
    end
  end

  def nearby_enemies
    DIRS.select { |dir| enemy?(dir) }
  end

  # Is enemy possible exist?
  def enemy_eliminated?
    items = listen

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

end

