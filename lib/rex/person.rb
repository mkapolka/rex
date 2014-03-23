require_relative 'room.rb'

class Person < Thing
    attr_accessor :holding, :wearing, :acted
    attr_accessor :event
    attr_accessor :opinions

    attr_accessor :writing_skill

    def initialize
        super
        self.wearing = []
        self.writing_skill = 0
    end

    def wear(clothing)
        in_slot = self.wearing.find{|x| x.slot == clothing.slot}
        if not in_slot.nil? then
            self.unwear in_slot
        end

        self.tell "I don #{clothing.name.downcase}."
        self.tell_others "#{self.name} puts on #{clothing.name.downcase}"
        self.wearing << clothing
        clothing.worn_by = self
    end

    def unwear(clothing)
        if self.wearing.delete clothing
            self.tell "I doff #{clothing.name.downcase}."
        end
    end

    def describe
        desc = super
        if self.holding != nil then
            desc += "\nThey're holding #{self.holding.name}."
        end
        if self.wearing.length > 0 then
            desc += "\n"
            desc += "They're wearing...\n\t"
            clothing_names = self.wearing.map{|x| x.name}
            desc += clothing_names.join("\n\t")
        end
        return desc
    end

    def leave_event(event)
        self.event = nil
        event.remove(self)
    end

    def join(event)
        self.event = event
        event.add(self)
    end

    def name
        if not self.holding.nil?
            return "#{super}, holding #{self.holding.name}"
        else
            return "#{super}"
        end
    end

    def in_room?(room, room_class=nil)
        if room.nil? and not room_class.nil?
            room = self.location.world.locations.find{|x| x.class == room_class}
        end
        self.location == room
    end

    def move(room)
        super
        self.wearing.each{|c| c.move(room)}
        self.holding.move(room) unless self.holding.nil?
    end

    def take_thing(thing)
        if thing.nil?
            self.tell "I can't pick up nothing!"
            return
        end

        thing_holder = thing.held_by
        if thing.held_by == self
            self.tell "I'm already holding that!"
            return
        else
            self._remove_thing_from_holder(thing)
        end

        self.holding = thing
        thing.held_by = self

        if not thing_holder.nil? then
            self.tell "I've taken #{thing.name} from #{thing_holder.name}"
            self.tell_others "#{self.name} takes #{thing.name} from #{thing_holder.name}"
        else
            self.tell "I've picked up #{thing.name}"
            self.tell_others "#{self.name} picks up #{thing.name}"
        end
    end

    def drop_thing(thing)
        if thing.nil?
            self.tell "I can't drop what isn't!"
            return
        end

        if self.holding != thing
            self.tell "I'm not holding that!"
            return
        end

        self.holding = nil
        thing.held_by = nil

        thing.move(self.location)
        self.tell "I've dropped the #{thing.name}"
        self.tell_others "#{self.name} drops #{thing.name}"
    end

    def say(what)
        self.tell_others "#{self.name} says, \"#{what}\""
    end

    def join_or_start_event(event_class, init_args=[])
        events = self.location.contents.map{|x| x.event if x.respond_to? :event}
        ongoing = events.find{|x| x.is_a? event_class}
        print ongoing
        unless ongoing.nil?
            self.join(ongoing)
        else
            self.join(event_class.new *init_args)
        end
    end
end
