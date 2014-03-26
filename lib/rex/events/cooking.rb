require 'active_support/core_ext/array/conversions'
require 'rex/places'
require 'rex/action'
require 'rex/player'

class CookingEvent  < Event
    REQUIRED_PREPAREDNESS = 2

    attr_accessor :preparedness

    def initialize
        super
        self.preparedness = 0
    end

    def describe
        if self.participants.length == 1
            return "#{self.participants[0].name.capitalize} is cooking dinner."
        else
            names = self.participants.map(&:name).to_sentence        
            return "#{names} are cooking dinner."
        end
    end

    def cook
        self.participants.find{|x| x.is_a? Cook}
    end

    def tick
        participants.each do |actor|
            if not actor.in_room? Kitchen
                actor.move actor.find_room Kitchen
            end
        end

        message = "#{cook.name} bustles around preparing dinner."
        self.cook.location.tell_everyone message

        # Player participant
        player = participants.find{|x| x.is_a? Player}
        unless player.nil?
            player.tell "#{self.cook.name} shares some juicy gossip with me and we bond over the experience."
            player.tell "I feel a bit more knowledgeable about cooking."
        end

        self.preparedness += participants.length

        if self.preparedness >= REQUIRED_PREPAREDNESS
            self.cook.say "Well! It looks like everything's ready."
        end
    end

    def assist_cook_action(player)
        if self.preparedness == REQUIRED_PREPAREDNESS - self.participants.length
            self.cook.say "Oh, I have it under control, you don't need to help."
            do_anyway = player.choose("Help anyway?", {'y' => '[y]es', 'n' => '[n]o'})
            if do_anyway == 'n'
                player.tell "Yeah, I guess there are better things to do."
                return false
            end
        end

        self.add(player)
        return true
    end

    def actions
        return [
            Action.new("Assist the cook."){|x| self.assist_cook_action(x)}
        ]
    end
end

