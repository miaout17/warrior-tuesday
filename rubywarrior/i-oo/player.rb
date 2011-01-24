require 'strategy/base'
require 'strategy/directional'
require 'strategy/undirectional'
require 'strategy/path_find'

DIRS = [:forward, :left, :backward, :right]
OFFSETS = {
  :forward => [1, 0],
  :backward => [-1, 0],
  :left => [0, -1],
  :right => [0, 1]
}

class Player

  attr_reader :warrior
  attr_reader :last_dir
  attr_reader :possible_enemy_count

  def initialize
    @last_dir = nil
    @detonate = false
    @initialized = false

    @strategies = [
      Strategy::RescueTicking,
      Strategy::RestWhenTicking,
      Strategy::WalkToTicking,
      Strategy::Bind,
      Strategy::Detonate,
      Strategy::Attack,
      Strategy::Rest, 
      Strategy::AttackMemorizedEnemy,
      Strategy::RescueCaptive,
      Strategy::WalkToSounds,
      Strategy::WalkToStairs
    ].map { |klass| klass.new(self) }
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

    @strategies.each do |strategy|
      break if strategy.evaluate
    end
    
    @last_health = @warrior.health
  end

  def detonated?
    @detonated
  end

  def remember_enemy?(dir)
    @enemies.include?(pos(dir))
  end

  def reverse_dir(dir)
    index = DIRS.index(dir)
    rev_index = (index+2) % 4
    DIRS[rev_index]
  end

  def walk!(dir)
    @pos = pos(dir)
    @last_dir = reverse_dir(dir)
    warrior.walk!(dir)
  end

  def detonate!(dir)
    @detonated = true
    warrior.detonate!(dir)
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

  def pos(dir=nil)
    offset = dir ? OFFSETS[dir] : [0, 0]
    [@pos[0]+offset[0], @pos[1]+offset[1]]
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

end
