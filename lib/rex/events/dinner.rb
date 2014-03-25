require 'rex/event.rb'

class DinnerEvent < Event
    def tick
        self.participants.each {|x| x.tell "Everyone has a really nice meal and nothing interesting happens at all."}
        self.end()
    end

    def describe
        names = self.participants.map(&:name).to_sentence
        return "#{names} are eating dinner."
    end
end
