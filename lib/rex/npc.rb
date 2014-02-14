require_relative 'event.rb'
require_relative 'memory.rb'

class NPC < Person
    attr_accessor :memories

    def initialize
        super
        self.memories = []
    end
    
    #Basic memory and scheduling tasks
    def witness(event)
        case event
        when MoveEvent
            old_location_memory = LocationMemory.new(event.from_location, event.thing, false)
            new_location_memory = LocationMemory.new(event.to_location, event.thing, true)
            # find old "current location" memory if it exists and replace it
            current_location_memory = self.memories.find do |memory|
                memory.thing == event.thing && memory.is_current
            end
            current_location_memory.is_current = false unless current_location_memory.nil?

            self.memories << old_location_memory
            self.memories << new_location_memory
        end
    end

    def memories_of_type(type)
        return self.memories.filter{|x| x.type == type}
    end
end
