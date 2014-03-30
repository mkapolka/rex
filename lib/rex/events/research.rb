class ResearchEvent < Event
    def tick(world)
        self.participants.each do |actor|
            messages = [
                "#{actor.name} fiddles with an orrery",
                "#{actor.name} looks through a telescope",
                "#{actor.name} thumbs through some books"
            ]

            actor.tell_others(messages[rand(message.length)])
        end
    end
end
