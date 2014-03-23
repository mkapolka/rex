require_relative 'thing.rb'
require_relative 'person.rb'
require_relative 'npc.rb'
require_relative 'prince.rb'

class Throne < Thing
    attr_accessor :seating

    self.name = "a golden throne"
    self.description = "This throne glitters in the sunlight."

    def sit(thing)
        if self.seating != thing
            thing.tell "I sit on the throne."
            thing.tell_others "#{thing.name} sits on the throne"
            self.seating = thing
        else
            thing.tell "I'm already sitting on that!"
        end
    end

    def stand(thing)
        if self.seating == thing
            thing.tell "I get up from the throne"
            thing.tell_others "#{self.name} rises from the throne."
            self.seating = nil
        end
    end
end

class Clothing < Thing
    class_attribute :slot
    attr_accessor :worn_by

    def don
        actor.wear self
    end

    def doff
        actor.remove_clothing self
    end
end

class Crown < Clothing
    self.carryable = true

    slot = "Head"

    self.name = "A sparkling crown"
    self.description = "He who wears it commands the kingdom."
end
