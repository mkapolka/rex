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
