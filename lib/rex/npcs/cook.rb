require 'rex/events/all.rb'
require 'rex/places'

class Cook < NPC
    self.name = 'the cook'
    self.description = "She prepares the meals for the castle. "\
                       "She's very strong from hoisting pigs onto the spit."

    def initialize
        super
        self.join(CookingEvent.new)
    end
end
