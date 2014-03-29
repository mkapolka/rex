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
end
