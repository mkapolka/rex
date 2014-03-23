require 'rex/events/all.rb'

class King < NPC
    self.name = "the king"
    self.description = "He rules!"

    def initialize
        super
        crown = Crown.new
        self.wear(crown)
        e = HoldCourtEvent.new
        self.join(e)
    end

    def tick
        super
        if self.time == World::TIME_EVENING
            self.say "Time for dinner!"
            self.leave_event(self.event)
            self.move self.find_room(DiningRoom)
            self.join_or_start_event(DinnerEvent)
        end
    end
end
