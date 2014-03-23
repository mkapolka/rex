require 'rex/event.rb'

class DinnerEvent < Event
    def tick
        self.participants.each {|x| x.tell "Everyone has a really nice meal and nothing interesting happens at all."}
        self.end()
    end
end
