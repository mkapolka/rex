require_relative 'room.rb'
require_relative 'places.rb'
require_relative 'things.rb'

class World
    TIME_MIDNIGHT = 0
    TIME_MORNING = 1
    TIME_MIDDAY = 2
    TIME_EVENING = 3
    TIME_NIGHT = 4

    attr_accessor :locations, :player
    attr_accessor :current_time, :current_day

    def initialize
        self.locations = []
        Room::_ROOMS.each do |room_class|
            locations << room_class.new(self)
        end
        locations.each(&:initialize_exits)
        self.player = Player.new
        self.player.transport(locations[0])

        self.current_time = TIME_MORNING
        self.current_day = 0
    end

    def tick
        self.advance_time

        # First, let the people do their own thing
        all_things = locations.reduce([]){|ary, loc| ary += loc.contents}
        all_things.each(&:tick)
        # Then do the activities
        activities = all_things.map(&:event).compact.uniq
        activities.each(&:tick)
    end

    def advance_time
        self.current_time += 1
        if self.current_time > TIME_NIGHT
            self.current_time = TIME_MIDNIGHT
            self.current_day += 1
        end
        case self.current_time
        when TIME_MORNING
            player.tell "Morning bells are ringing in the distance."
        when TIME_MIDDAY
            player.tell "It's mid day."
        when TIME_EVENING
            player.tell "I can hear the evening bells ringing."
        when TIME_NIGHT
            player.tell "The sun sunk below the horizon."
        when TIME_MIDNIGHT
            player.tell "It must be about midnight now."
        end
    end

    def find_room(room_name)
        return self.locations.find{|room| room.class.name == room_name.to_s}
    end
end
