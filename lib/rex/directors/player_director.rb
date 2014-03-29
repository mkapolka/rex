require 'rex/director'
require 'rex/parser'

class PlayerDirector < Director
    self.actor_class = Player

    attr_accessor :parser

    def initialize(world)
        super(world)
        self.parser = Parser.new
    end

    def tick
        unless self.actor.occupied?
            self.parser.prompt(self.actor, self.world)
        end
    end

    def look
    end
end
