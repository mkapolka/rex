require_relative 'room.rb'
require_relative 'things.rb'
require_relative 'player.rb'
require 'rex/parser'
require 'rex/npcs/all.rb'

class ThroneRoom < Room
    self.description = "The room is suffused with bright sunlight."
    self.title = "The Throne Room"
    self.contents = [
        King
    ]
end

class Kitchen < Room
    self.description = "Cured meats are hanging from the ceiling."
    self.title = "The Kitchen"
    self.contents = [
        Cook
    ]
end

class DiningRoom < Room
    self.description = "The nearer you are to the head of the table the more important you are."
    self.title = "The Dining Room"
    self.contents = []
end

class RoyalBedroom < Room
    self.description = "The King and Queen's Royal Bedchambers."
    self.title = "The Royal Bedroom"
end

class MyRoom < Room
    self.description = "This is my room. Here, at least, I can expect some privacy."
    self.title = "My Room"
    self.contents = [Player]

    def actions
        [
            Action.new("Go to sleep") do |actor|
                self.sleep_prompt(actor)
            end
        ]
    end

    def sleep_prompt(actor)
        if self.world.current_time < World::TIME_EVENING
            response = choose("It's not very late yet. Should I really go to sleep?", {'y' => '[y]es', 'n' => '[n]o'})
            if response == 'n'
                return false
            end
        end
        actor.tell "I lie down and go to sleep."
        actor.join_event(SleepEvent.new(self.world))
    end
end

class OctaviusRoom < Room
    self.description = "This is Octavius' room. It's a pigsty."
    self.title = "Octavius' Room"
end
