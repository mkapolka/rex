require_relative 'room.rb'

class Person < Thing
    attr_accessor :holding, :wearing, :acted, :holding
    attr_accessor :opinions

    def tell(what)
        # Do nothing by default
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
        elsif not thing.held_by.nil?
            thing.held_by.holding = nil
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
