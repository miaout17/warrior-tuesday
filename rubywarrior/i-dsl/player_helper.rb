require 'forwardable'

module PlayerHelper

  DIRS = [:forward, :left, :backward, :right]
  OFFSETS = {
    :forward => [1, 0], 
    :backward => [-1, 0], 
    :left => [0, -1], 
    :right => [0, 1]
  }

  class StrategyDefinition

    def initialize(klass)
      @klass = klass
    end

    def strategy(action=nil, filter=nil, &block)
      action_method_s, filter_method_s = _bind_methods(action, filter, &block)
      @klass.class_eval do
        perform_method_s = "_strategy_perform_#{@strategries.count}"

        define_method(perform_method_s) do
          send(action_method_s) if filter_method_s ? send(filter_method_s) : true
        end

        @strategries << perform_method_s.to_sym
      end
    end

    def directional(action=nil, filter=nil, &block)
      action_method_s, filter_method_s = _bind_methods(action, filter, &block)

      @klass.class_eval do
        perform_method_s = "_strategy_perform_#{@strategries.count}"

        define_method(perform_method_s) do
          DIRS.each do |dir|
            send(action_method_s, dir) if filter_method_s ? send(filter_method_s, dir) : true
            break if @action_taken
          end
        end

        @strategries << perform_method_s.to_sym
      end
    end

    def _bind_methods(action=nil, filter=nil, &block)
      action_method_s = nil
      filter_method_s = nil
      @klass.class_eval do
        if action
          action_method_s = action
          if filter
            filter_method_s = filter
          elsif block
            filter_method_s = "_strategy_filter_#{@strategries.count}"
            define_method(filter_method_s, block)
          end
        else
          action_method_s = "_strategy_action_#{@strategries.count}"
          define_method(action_method_s, block)
        end
      end
      [action_method_s, filter_method_s]
    end

  end

  module ClassMethods

    include Forwardable

    def actions(*methods)
      methods.each { |m| _define_action(m) }
    end

    def senses(*methods)
      def_delegators(:@warrior, *methods)
    end

    def _define_action(method)
      method = method.to_s
      class_eval <<-EOS
        def #{method}(*args)
          invoke_callback(:before, :#{method}, *args)
          @warrior.#{method}(*args)
          @action_taken = true
          invoke_callback(:after, :#{method}, *args)
        end
      EOS
    end

    def strategries
      @strategries ||= []
      @strategries
    end

    def def_strategries(&block)
      @strategries = []

      definition = StrategyDefinition.new(self).instance_eval(&block)
    end
    
    def on_start(&block)
      define_method(:_on_start, &block)
    end

    %w{before after}.each do |timing|
      class_eval <<-EOS
        def #{timing}(*actions, &block)
          actions.each do |action|
            action = action.to_s
            define_method("_callback_#{timing}_\#{action}", &block)
          end
        end
      EOS
    end

  end

  module InstanceMethods
    
    def strategries
      self.class.strategries
    end

    def invoke_callback(timing, action, *args)
      callback = "_callback_#{timing}_#{action}"
      send(callback, *args) if respond_to?(callback)
    end

    def play_turn(warrior)
      @action_taken = false
      @warrior = warrior

      unless @initialized
        _on_start if respond_to?(:_on_start)
        @initialized = true
      end

      invoke_callback(:before, :play_turn)
      strategries.each do |action, filter|
        valid = filter ? send(filter) : true
        send(action) if valid
        break if @action_taken
      end
      invoke_callback(:after, :play_turn)
    end

    def reverse_dir(dir)
      index = DIRS.index(dir)
      rev_index = (index+2) % 4
      DIRS[rev_index]
    end

    def method_missing(method, *args)
      # deletate methods such as enemy?, empty?
      # Ex. enemy?(dir) => feel(dir).enemy?
      if method.to_s =~ /.*?$/ && RubyWarrior::Space.instance_methods(false).map(&:to_sym).include?(method)
        feel(*args).send(method)
      else
        super
      end
    end

  end

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

end
