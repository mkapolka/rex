require 'active_support/core_ext/array/conversions'
require_relative 'action.rb'

class Event
    include ActionContainer

    attr_accessor :participants
    def initialize
        self.participants = []
    end

    def describe
        return "#{self.participants.to_sentence} are engaged in some mysterious errand."
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
