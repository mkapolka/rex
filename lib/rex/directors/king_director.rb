require 'rex/world'
require 'rex/npcs/king'
require 'rex/events/all'

class KingDirector < Director
    self.actor_class = King

    def tick
        case self.world.current_time
        when World::TIME_MORNING, World::TIME_MIDDAY
            event = self.join_or_start_event(self.actor, world, HoldCourtEvent)
        when World::TIME_EVENING
            self.actor.say "Time for dinner!"
            events = self.world.events_including(self.actor)
            events.each do |event|
                event.remove(self.actor) if event.engrossing?(self.actor)
            end
            self.world.move_thing(self.actor, self.world.find_room(DiningRoom))
            self.join_or_start_event(self.actor, self.world, DinnerEvent)
        end
    end
end
