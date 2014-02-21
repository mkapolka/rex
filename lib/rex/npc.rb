require_relative 'event.rb'
require_relative 'memory.rb'
require_relative 'state.rb'

class NPC < Person
    attr_accessor :memories, :state

    def initialize
        super
        self.memories = []
        self.state = WaitState.new(1)
    end

    def tick
        super
        self.tick_state self.state
    end

    def tick_state(state)
        case state
        when WaitState
            self.wait_tick state
        when WanderState
            self.wander_tick state
        when FollowState
            self.follow_tick state
        end
    end

    def wait_tick(state)
        state.timer -= 1
        if state.timer < 0
            self.decide_next_state
        end
    end

    def wander_tick(state)
        if self.location != state.target_location then
            self.move_towards(state.target_location)
        else
            self.decide_next_state
        end
    end

    def follow_tick(state)
        if self.location != state.following.location then
            target_room = remember_where_is state.following
            unless target_room.nil?
                self.move_towards target_room
            else
                self.tell_others "#{self.name} says, \"Drat! I've lost track of #{state.following.name}\""
                self.decide_next_state
            end
        end
    end

    def decide_next_state
        case self.state
        when WaitState
            reachable = reachable_rooms
            new_target_room = reachable[Random::rand(reachable.length)]
            self.tell_others "#{self.name} says, \"I think I'll go to #{new_target_room.title}\""
            self.state = WanderState.new(new_target_room)
        when WanderState
            self.tell_others "#{self.name} decides to wait here for a while"
            self.state = WaitState.new(Random::rand(10))
        when FollowState
            self.state = WaitState.new(Random::rand(3))
        else
            self.state = WaitState.new(10)
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

    def remember_where_is(thing)
        thing_memories = self.memories.select do |memory|
            memory.class == LocationMemory and
            memory.thing == thing and 
            memory.is_current == true
        end

        return thing_memories[0].location
    end

    def memories_of_type(type)
        return self.memories.filter{|x| x.type == type}
    end

    def move_towards(room)
        # Find the shortest path
        if room != self.location
            paths = self.location.exits.map{|exit| self._path_distance(self.location, room)}
            paths.sort{|p1, p2| p1[0] <=> p2[0]}
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

    def move(room)
        old_location = self.location
        self.tell_others "#{self.name} moves to #{room.title.downcase}"
        super
        self.tell_others "#{self.name} comes in from #{old_location.title.downcase}"
    end
end
