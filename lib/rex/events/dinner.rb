require 'rex/event.rb'

class DinnerEvent < Event
    def tick(world)
        self.participants.each {|x| x.tell "Everyone has a really nice meal and nothing interesting happens at all."}
        self.end()
    end

    def describe
        if participants.length > 1 then
            names = self.participants.map(&:name).to_sentence
            return "#{names} are eating dinner."
        else
            return "#{participants[0].name} is eating dinner."
        end
    end

    def actions
        return [Action.new("Eat dinner"){|x| self.add(x)}]
    end
end
