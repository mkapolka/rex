require 'rex/events/all.rb'
require 'rex/places.rb'

class Scholar < NPC
    self.name = "the scholar"
    self.description = "He researches the mysteries of the world."

    def intiialize
        super
        self.event = ResearchEvent.new
    end
end
