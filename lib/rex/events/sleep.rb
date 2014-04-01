require 'rex/event'
require 'rex/world'


class SleepEvent < Event
    #WAKE_UP_TIME = World::TIME_MIDNIGHT

    def tick(world)
        if world.current_time != World::TIME_MIDNIGHT
            self.participants.each do |actor|
                actor.tell "zzz..."
                actor.sleeping = true
                actor.occupied = true
            end
        else
            participants.each do |actor|
                actor.tell "What a good night's sleep!"
                actor.sleeping = false
                actor.occupied = false
            end
            self.end
        end
    end
end
