require 'rex/world'
require 'rex/npcs/king'
require 'rex/events/all'

class KingDirector < Director
    self.actor_class = King

    def tick
        case self.world.current_time
        when [World::TIME_MORNING, World::TIME_MIDDAY]
            event = self.world.events.find{|x| x.participants.find(self.actor)}
            if event.nil?
                event = HoldCourtEvent.new
                event.add(self.actor)
                world.add_event(event)
            end
        end
        
        if self.world.current_time == World::TIME_EVENING
            self.actor.say "Time for dinner!"
            self.actor.leave_event(self.event)
            self.actor.move self.world.find_room(DiningRoom)
            self.actor.join_or_start_event(DinnerEvent)
        end
    end
end
