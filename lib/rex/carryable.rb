module Carryable
    def self.included(cls)
        cls.instance_exec do
            attr_accessor :held_by
        end

        cls.parseable_action 'take',:self do |actor|
            actor.take_thing(self)
        end

        cls.parseable_action 'drop', :self do |actor|
            actor.drop_thing(self)
        end
    end
end
