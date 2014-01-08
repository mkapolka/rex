require_relative 'actions.rb'

class Thing
    include ActionContainer

    class_attribute :actions, :name, :description
    attr_accessor :location

    def initialize
        self.actions = []
    end

    def move(room)
        if not self.location.nil?
            location.contents.delete self
        end

        room.contents.push self
        self.location = room
    end

    def tick
        # Default implementation- do nothing
    end
end
