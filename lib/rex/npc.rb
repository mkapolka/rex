require_relative 'event.rb'

class NPC < Person
    attr_accessor :memories

    def tick
        super
        if self.event.nil? then
            self.decide_next_event
        end
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

    def move(room)
        old_location = self.location
        self.tell_others "#{self.name} moves to #{room.title.downcase}"
        super
        self.tell_others "#{self.name} comes in from #{old_location.title.downcase}"
    end

    def in_room?(room_class)
        self.location.is_a? room_class
    end
end
