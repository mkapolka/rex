require_relative 'room.rb'
require_relative 'places.rb'
require_relative 'things.rb'

class World
    attr_accessor :locations, :player

    def initialize
        self.locations = []
        locations << ThroneRoom.new(self)
        locations << Foyer.new(self)
        locations.each(&:initialize_exits)
        self.player = Player.new
        self.player.move(locations[0])
    end

    def tick
        all_things = locations.reduce([]){|ary, loc| ary += loc.contents}
        all_things.each(&:tick)
    end

    def find_room(room_name)
        return self.locations.find{|room| room.class.name == room_name.to_s}
    end
end
