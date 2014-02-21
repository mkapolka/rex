require_relative 'npc.rb'

class King < NPC
    self.name = "the king"
    self.description = "He rules!"

    def initialize
        super
        crown = Crown.new
        self.wear(crown)
    end
end

class Maid < NPC
    self.name = "the maid"
    self.description = "Her job is to clean the castle."

    attr_accessor :cleaned_rooms, :state

    def initialize
        super
        self.cleaned_rooms = []
    end

    def tick_state
        case self.state
        when CleanState
            if self.location != self.state.target_room
                self.move_towards(self.state.target_room)
            else
                self.tell_others "#{self.name} cleans some stuff."
            end
        else
            super
        end
    end

    def decide_next_state
        case self.state
        when WaitState
            self.tell_others "#{self.name} thinks about which room to clean next..."
            remaining_rooms = reachable_rooms - self.cleaned_rooms
            next_room = remaining_rooms[0]
            self.tell_others "#{self.name} decides to clean #{next_room.title.downcase}"
            self.state = CleanState.new(next_room)
        end
    end
end

class CleanState < State
    attr_accessor :target_room

    def initialize(target_room)
        self.target_room = target_room
    end
end

class WetNurse < NPC
    self.name = "my wet nurse"
    self.description = "She's responsible for my safety"

    def item_stolen(item, by_whom)
        self.tell_others "#{self.name.capitalize} says 'Hey, give that #{item.name} back!'"
    end

    parseable_action 'talk', :self do |actor|
        actor.tell "#{self.name.capitalize} tells me to remember to wash behind my ears!"
    end
end

