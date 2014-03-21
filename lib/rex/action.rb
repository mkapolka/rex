
class Action
    attr_accessor :name, :mnemonic

    def do(user)
        # Should return true if this action consumed the player's turn
        # False if it did not.
        return false
    end
end

module ActionContainer
    def self.included(cls)
        cls.instance_eval do
            def actions
                @actions ||= []
            end
        end
    end

    def self.action(name, mnemonic, &callback)
        action = Action.new
        action.name = name
        action.mnemonic = mnemonic
    end
end
