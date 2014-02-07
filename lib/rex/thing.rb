require_relative './parseable_action.rb'

class Thing
    extend ParseableAction

    class_attribute :name, :description, :destroyed
    attr_accessor :location

    def initialize
        self.destroyed = false
    end

    def move(room)
        if not self.location.nil?
            location.contents.delete self
        end

        if not room.nil?
            room.contents.push self
            self.location = room
        end
    end

    def destroy
        self.move(nil)
        self.destroyed = true
    end

    def tick
        # Default implementation- do nothing
    end

    def describe
        
    end

    parseable_action 'look', :self do |actor|
        string = "You see here #{self.name}\n"
        string += self.description + "\n"
        # Add parsable actions
        action_strings = self.class.parser_commands.map do |key, command|
            "'#{command.name}' #{command.preposition}".strip
        end
        if action_strings.length > 1 then
            s1 = action_strings[0...-1].join(', ')
            s2 = " or #{actions[-1]}"
            string += "It looks like you could "
            string += "#{action_strings[0...-1].join(', ')} or #{action_strings[-1]}"
            string += " this thing."
        elsif action_strings.length == 1 then
            string += "It looks like you could #{action_strings[0]} this thing."
        end
        actor.tell(string)
    end
end
