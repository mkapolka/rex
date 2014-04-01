class Director
    class_attribute :actor_class
    attr_accessor :actor, :world

    def initialize(world, actor=nil)
        self.world = world
        if actor.nil?
            self.actor = world.things.find{|x| x.is_a? self.actor_class}
        end
    end

    def tick
    end

    def join_or_start_event(actor, world, event_class)
        event = self.world.events.find{|x| x.is_a? event_class}
        if event.nil?
            event = event_class.new(world)
            self.world.add_event(event)
        end

        event.add(actor)
        return event
    end
end
