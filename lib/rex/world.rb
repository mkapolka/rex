require_relative 'room.rb'
require_relative 'places.rb'
require_relative 'things.rb'

class World
    attr_accessor :locations, :player

    def initialize
        self.locations = []
        Room::_ROOMS.each do |room_class|
            locations << room_class.new(self)
        end
        locations.each(&:initialize_exits)
        self.player = Player.new
        self.player.transport(locations[0])
    end

    def tick
        # First, let the people do their own thing
        all_things = locations.reduce([]){|ary, loc| ary += loc.contents}
        all_things.each(&:tick)
        # Then do the activities
        activities = all_things.map(&:event).compact.uniq
        activities.each(&:tick)
    end

    def find_room(room_name)
        return self.locations.find{|room| room.class.name == room_name.to_s}
    end
end
