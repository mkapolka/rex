require_relative 'npc.rb'

class King < NPC
    self.name = "the king"
    self.description = "He rules!"

    def initialize
        super
        crown = Crown.new
        self.wear(crown)
    end

    def tick
    end
end

class Maid < NPC
    self.name = "the maid"
    self.description = "Her job is to clean the castle."

    attr_accessor :cleaned_rooms, :state

    STATE_NOT_BUSY = :not_busy
    STATE_CLEANING = :cleaning
    STATE_DONE = :done

    def initialize
        super
        self.cleaned_rooms = []
        self.state = STATE_NOT_BUSY
    end

    def tick
        super
        self.move_towards(self.location.world.find_room(:ThroneRoom))
        case self.state
        when STATE_NOT_BUSY
            tick_not_busy
        end
    end

    def tick_not_busy
        self.tell_others "#{self.name} thinks about which room to clean next..."
        remaining_rooms = reachable_rooms - self.cleaned_rooms
        unless remaining_rooms.empty?
            next_room = remaining_rooms[0]
            self.tell_others "#{self.name} decides to clean #{next_room.title.downcase}"
            #self.state = STATE_CLEANING
        end
    end
end
