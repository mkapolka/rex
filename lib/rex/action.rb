class Action
    attr_accessor :name, :callback

    def initialize(name, &callback)
        self.name = name
        self.callback = callback
    end

    def do(player)
        # Should return true if this action consumed the player's turn
        # False if it did not.
        unless self.callback.nil?
            return self.callback.call(player)
        else
            return false
        end
    end
end

module ActionContainer
    def self.included(cls)
        cls.instance_eval do
            def self.actions
                @actions ||= []
            end

            def self.action(name, &callback)
                action = Action.new name
                action.callback = callback
                self.actions << action
            end
        end
    end

    def actions
        return self.class.actions
    end
end
