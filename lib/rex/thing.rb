require_relative './parseable_action.rb'
require_relative './parser_command.rb'
require_relative 'event.rb'

class Thing
    extend ParseableAction

    class_attribute :name, :description
    attr_accessor :location, :destroyed

    def initialize
        self.destroyed = false
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
            old_room = self.location
            move_event = MoveEvent.new(self, old_room, room)
            old_room.deliver_event(move_event) unless old_room.nil?
            self.transport(room)
            room.deliver_event(move_event) unless room.nil?
        end
    end

    def destroy
        self.transport(nil)
        self.destroyed = true
    end

    def tick
        # Default implementation- do nothing
    end

    def describe
        string = "I see here #{self.name}\n"
        string += self.description + "\n" if self.description
        # Add parsable actions
        action_strings = self.class.parser_commands.map do |command|
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

    #parseable_action 'look', :self do |actor|
    parser_command 'look', :self do |user|
        user.player.tell(self.describe)
    end

    def inspect
        return self.name
    end
end
