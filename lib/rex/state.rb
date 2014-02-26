class State
end

class WanderState < State
    attr_accessor :target_location

    def initialize(target_location)
        self.target_location = target_location
    end
end

class WaitState < State
    attr_accessor :timer

    def initialize(timer)
        self.timer = timer
    end
end

class FollowState < State
    attr_accessor :following

    def initialize(following)
        self.following = following
    end
end

class SearchState < State
    attr_accessor :target, :searched_rooms

    def initialize(target)
        self.target = target
    end

    def search_room(room)
        self.searched_rooms << room unless self.searched_rooms.find(room)
    end
end
