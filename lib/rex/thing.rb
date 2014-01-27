require_relative './parseable_action.rb'

class Thing
    extend ParseableAction

    class_attribute :name, :description
    attr_accessor :location

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
