class Memory
    # Location: Memories of where things have been
    TYPE_CURRENT_LOCATION = :current_location
    TYPE_PREVIOUS_LOCATION = :previous_location

    attr_accessor :type, :properties, :time_created
end

class LocationMemory < Memory
    attr_accessor :location, :thing, :is_current

    def initialize(location, thing, is_current)
        self.location = location
        self.thing = thing
        self.is_current = is_current
    end
end
