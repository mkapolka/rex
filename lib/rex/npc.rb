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

    def move_towards(room)
        # Find the shortest path
        if room != self.location
            paths = self.location.exits.map{|exit| self._path_distance(self.location, room)}
            paths.sort{|p1, p2| p1[0] <=> p2[0]}
            puts "#{self.name} moves towards #{room.title} by way of #{paths[0][1].title}"
            self.move(paths[0][1])
        end
    end

    def _path_distance(current_room, target_room, visited=[])
        lowest_distance = nil
        lowest_room = nil
        current_room.exits.each do |exit|
            if exit.room == target_room then
                distance = 1
            elsif not visited.index(exit.room)
                new_visited = visited + [current_room]
                d = _path_distance(exit.room, target_room, new_visited)
                distance = 1 + d[0] unless d[0].nil?
            end

            if not distance.nil? and (lowest_distance.nil? or lowest_distance > distance)
                lowest_distance = distance
                lowest_room = exit.room
            end
        end
        return lowest_distance, lowest_room
    end

    def reachable_rooms
        reachable_rooms = []
        rooms = [self.location]
        while not rooms.empty? do
            room = rooms.pop
            reachable_rooms.push(room)
            room.exits.each do |exit|
                rooms.push(exit.room) unless reachable_rooms.index(exit.room)
            end
        end
        return reachable_rooms
    end

end
