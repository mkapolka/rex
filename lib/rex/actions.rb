require 'active_support/core_ext/class/attribute'

class Action
    attr_accessor :name, :function
    def initialize(name, &function)
        self.name = name
        self.function = function
    end
end

module ActionContainer
    module ClassMethods
        def self.extended(cls)
            cls.class_attribute :actions
            cls.actions = {}
        end

        # Action definitions should take the following parameters:
        #   Actor, direct object, indirect object
        def action(name, &function)
            self.actions = self.actions.dup
            action = Action.new(name, &function)
            self.actions[name] = action
        end
    end

    def self.included(cls)
        cls.extend ClassMethods
    end

    def call_action(action_name, *args)
        instance_exec(*args, &self.actions[action_name].function)
    end
end
