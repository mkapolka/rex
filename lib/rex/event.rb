require 'active_support/core_ext/array/conversions'
require_relative 'action.rb'

class Event
    include ActionContainer

    attr_accessor :participants, :done
    def initialize
        self.participants = []
        self.done = false
    end

    def describe
        return "#{self.participants.to_sentence} are engaged in some mysterious errand."
    end

    def tick
    end

    def add(actor)
        self.participants << actor unless self.participants.index(actor)
    end

    def remove(actor)
        self.participants.delete(actor)
    end

    def end
        self.done = true
    end

    def escapable?
        return true
    end

    def escape_clause
        return "Should I keep doing this?"
    end
end
