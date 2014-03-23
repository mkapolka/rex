require 'active_support/core_ext/array/conversions'

class Event
    attr_accessor :participants
    def initialize
        self.participants = []
    end

    def describe
        return "#{self.participants.to_sentence} engaging in some mysterious errand."
    end

    def tick
    end

    def add(actor)
        self.participants << actor
    end

    def remove(actor)
        self.participants.delete(actor)
    end

    def end
        participants.each{|participant| participant.leave_event(self)}
    end
end
