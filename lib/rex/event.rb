class Event
    attr_accessor :type, :name, :properties
end

class MoveEvent < Event
    # Triggered when something moves from one place to another
    attr_accessor :from_location, :to_location, :thing

    def initialize(thing, from_location, to_location)
        self.thing = thing
        self.from_location = from_location
        self.to_location = to_location
    end
end
