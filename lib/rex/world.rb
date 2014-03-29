require_relative 'room.rb'
require_relative 'places.rb'
require_relative 'player.rb'

class World
    TIME_MIDNIGHT = 0
    TIME_MORNING = 1
    TIME_MIDDAY = 2
    TIME_EVENING = 3
    TIME_NIGHT = 4

    attr_accessor :locations, :player, :events
    attr_accessor :current_time, :current_day

    def initialize
        self.locations = []
        Room::_ROOMS.each do |room_class|
            locations << room_class.new(self)
        end
        locations.each(&:initialize_exits)
        all_things = locations.reduce([]){|memo, obj| memo += obj.contents}
        players = all_things.select{|x| x.is_a? Player}
        if players.length != 1
            raise Exception.new "#{players.length} instances of `Player` found in the world! Please use exactly one. Current locations: #{players.map(&:location).map(&:name).join(", ")}"
        end
        self.player = players[0]

        self.current_time = TIME_MIDNIGHT
        self.current_day = 0
        self.events = []
    end

    def add_event(event)
        self.events << event
    end

    def remove_event(event)
        self.events.delete(event)
    end

    def add(thing, location)
        location.add(thing)
        things << thing
    end

    def things
        return (self.locations.map{|x| x.contents}).flatten
    end

    def events_in(room)
        return (room.contents.map{|x| x.event if x.respond_to? :event}).compact.uniq
    end

    def location(thing)
        return self.locations.find{|x| x.contents.find(thing)}
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
