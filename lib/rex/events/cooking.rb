require 'rex/places'

class CookingEvent  < Event
    def tick
        participants.each do |actor|
            if not actor.in_room? Kitchen
                actor.move actor.find_room Kitchen
            else
                messages = [
                    "#{actor.name} turns the spit.",
                    "#{actor.name} chops some onions.",
                    "#{actor.name} slices an apple.",
                    "#{actor.name} grinds up some spices.",
                    "#{actor.name} grills up an onion.",
                    "#{actor.name} throws a potato into the stew."
                ]

                actor.tell_others(messages[rand(messages.length)])
            end
        end
    end
end

