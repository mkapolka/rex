require 'active_support/core_ext/class/attribute'
require_relative 'action.rb'

class Room
    include ActionContainer

    def self._ROOMS
        @_ROOMS ||= []
        return @_ROOMS
    end

    def self.inherited(cls)
        # Cuz I'm a big ol' lazy and don't want to update World
        # every time I make a new room.
        self._ROOMS << cls
    end

    class_attribute :description, :title, :class_exits, :contents
    attr_accessor :contents, :world, :exits

    def initialize world
        self.contents = []
        self.class.contents ||= []
        self.class.contents.each do |thing_class|
            thing = thing_class.new
            thing.transport(self)
        end
        self.world = world
    end

    def initialize_exits
        self.exits = []
        if class_exits then
            self.class_exits.each do |exit|
                room = self.world.find_room(exit.room_name)
                if room.nil?
                    raise "Couldn't find room #{exit.room_name}!!"
                end
                exit.room = room
                self.exits << exit
            end
        end
    end

    def find_exit(direction)
        return self.exits.find{|exit| exit.direction == direction}
    end

    def self.exit direction, room_name
        self.class_exits ||= []
        self.class_exits << Exit.new(direction, room_name)

        self.parser_command direction do |user|
            user.player.move(self.find_exit(direction).room)
            user.player.call_parser_command('look', user)
            user.acted = true
        end
    end

    def inspect
        return "{#{self.title} (containing #{self.contents.map(&:name).join(', ')})}"
    end

    def deliver_event(event)
        self.contents.each do |thing|
            thing.witness(event) if thing.respond_to? :witness
        end
    end

    def tell_everyone(message)
        self.contents.each do |thing|
            thing.tell(message)
        end
    end
end

class Exit
    attr_accessor :direction, :room_name, :room

    def initialize direction, room_name
        self.direction = direction
        self.room_name = room_name
        self.room = room
    end
end
