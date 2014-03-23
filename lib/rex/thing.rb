require_relative 'event.rb'
require_relative 'action.rb'

class Thing
    include ActionContainer

    class_attribute :name, :description, :carryable
    attr_accessor :location, :destroyed
    attr_accessor :held_by

    def initialize
        self.destroyed = false
    end

    def inspect
        return self.name
    end

    def transport(room)
        # The more medical version of "move".
        # Moves the Thing to that location but doesn't trigger any callbacks
        if not self.location.nil?
            location.contents.delete self
        end

        self.location = room

        if not room.nil?
            room.contents.push self
        end
    end

    def move(room)
        if room != self.location then
            self.transport(room)
        end
    end

    def find_room(room_class)
        self.location.world.locations.find{|x| x.class == room_class}
    end

    def destroy
        self.transport(nil)
        self.destroyed = true
    end

    def tick
        # Default implementation- do nothing
    end

    def describe
        string = "That is #{self.name}\n"
        string += self.description + "\n" if self.description
        # Add parsable actions
        action_strings = self.class.actions.map do |command|
            "'#{command.name}' #{command.preposition}".strip
        end
        if action_strings.length > 1 then
            s1 = action_strings[0...-1].join(', ')
            s2 = " or #{actions[-1]}"
            string += "It looks like I could "
            string += "#{action_strings[0...-1].join(', ')} or #{action_strings[-1]}"
            string += " this thing."
        elsif action_strings.length == 1 then
            string += "It looks like I could #{action_strings[0]} this thing."
        end
        return string
    end

    def produce(event)
        self.location.contents.each do |thing|
            thing.witness event if thing.respond_to? :witness
        end
    end

    def tell(what)

    end

    def tell_others(what)
        unless self.location.nil?
            self.location.contents.each do |content|
                content.tell(what) if content != self
            end
        end
    end

    def time
        self.location.world.current_time
    end
end
