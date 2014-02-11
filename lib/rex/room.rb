require_relative 'parseable_action.rb'
require 'active_support/core_ext/class/attribute'

class Room
    extend ParseableAction

    class_attribute :description, :title, :class_exits, :contents
    attr_accessor :contents, :world, :exits

    def initialize world
        self.contents = []
        self.class.contents.each do |thing_class|
            thing = thing_class.new
            thing.move(self)
        end
        self.world = world
    end

    def initialize_exits
        self.exits = []
        if class_exits then
            self.class_exits.each do |exit|
                room = self.world.find_room(exit.room_name)
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
