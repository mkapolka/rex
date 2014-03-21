require_relative 'thing.rb'
require_relative 'person.rb'
require_relative 'npc.rb'

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

class Player < Person
    self.name = "me"

    def tell(string)
        puts string
        puts ""
    end

    def look
        self.tell "#{location.title}\n#{location.description}"
        things = self.location.contents
        ignored = things.each.reduce [] do |memo, obj|
            memo << obj.holding if obj.respond_to? :holding
            memo += obj.wearing if obj.respond_to? :wearing
            memo
        end
        names = (things - ignored).map(&:name)
        things_description = names.join("\n\t")
        self.tell "I see here...\n\t#{things_description}"
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
