require_relative 'room.rb'

class Person < Thing
    attr_accessor :holding, :wearing, :acted, :holding
    attr_accessor :opinions

    def tell
        # Do nothing by default
    end

    def learn(information)

    end

    def see(event)
        
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

        self.holding = thing
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

        thing.move(self.location)
        self.tell "You drop the #{thing.name}"
    end
end
