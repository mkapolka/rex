require_relative 'room.rb'
require_relative 'places.rb'
require_relative 'things.rb'

class World
    attr_accessor :locations, :player

    def initialize
        self.locations = []
        locations << ThroneRoom.new
        self.player = Player.new
        self.player.move(locations[0])
    end

    def tick
        locations.each do |location|
            location.contents.each(&:tick)
        end
    end
end
