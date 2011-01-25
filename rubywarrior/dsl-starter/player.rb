require 'player_helper'

class Player

  include PlayerHelper

  actions :walk!

  def_strategries do
    # stragegy { attack! if enemy? }
    strategy(:walk!)
  end

  on_start { puts "一位勇士開始了他的冒險" }
  after(:walk!) { puts "衝啊" }

end
