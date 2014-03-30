require 'active_support/core_ext/class/attribute'
require_relative 'action.rb'

class Room
    include ActionContainer

    def self._ROOMS
        @_ROOMS ||= []
        return @_ROOMS
    end

    def self.inherited(cls)
        # Cuz I'm a big ol' lazy and don't want to update World
        # every time I make a new room.
        self._ROOMS << cls
    end

    class_attribute :description, :title, :contents
    attr_accessor :contents

    def initialize world
        self.contents = []
        self.class.contents ||= []
        self.class.contents.each do |thing_class|
            thing = thing_class.new
            self.add(thing)
        end
    end

    def add(thing)
        self.contents << thing unless self.contents.index(thing)
        thing.location = self
    end

    def remove(thing)
        self.contents.delete(thing)
        thing.location = nil
    end

    def inspect
        return "{#{self.title} (containing #{self.contents.map(&:name).join(', ')})}"
    end

    def tell_everyone(message)
        self.contents.each do |thing|
            thing.tell(message)
        end
    end
end
