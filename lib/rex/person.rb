require_relative 'room.rb'

class Person < Thing
    attr_accessor :holding, :wearing, :acted, :holding, :wearing
    attr_accessor :opinions

    def initialize
        super
        self.wearing = []
    end

    def wear(clothing)
        in_slot = self.wearing.find{|x| x.slot == clothing.slot}
        if not in_slot.nil? then
            self.unwear in_slot
        end

        self.tell "You don #{clothing.name}."
        self.tell_others "#{self.name} puts on #{clothing.name}"
        self.wearing << clothing
        clothing.worn_by = self
    end

    def unwear(clothing)
        if self.wearing.delete clothing
            self.tell "You remove #{clothing.name}."
        end
    end

    def learn(information)

    end

    def see(event)
        
    end

    def name
        if not self.holding.nil?
            return "#{super}, holding #{self.holding.name}"
        else
            return "#{super}"
        end
    end

    def move(room)
        super
        self.holding.move(room) unless self.holding.nil?
    end

    def take_thing(thing)
        if thing.nil?
            self.tell "You can't pick up nothing!"
            return
        end

        if thing.held_by == self
            self.tell "You're already holding that!"
            return
        elsif not thing.held_by.nil? and thing.held_by != self
            thing.held_by.holding = nil
            thing.held_by.item_stolen(thing, self) if thing.held_by.respond_to? :item_stolen
        end

        self.holding = thing
        thing.held_by = self
        self.tell "You pick up #{thing.name}"
    end

    def drop_thing(thing)
        if thing.nil?
            self.tell "You can't drop what isn't!"
            return
        end

        if self.holding != thing
            self.tell "You aren't holding that!"
            return
        end

        self.holding = nil
        thing.held_by = nil

        thing.move(self.location)
        self.tell "You drop the #{thing.name}"
    end
end
