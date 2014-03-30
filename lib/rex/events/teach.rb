require 'rex/npcs/all'

class TeachEvent < Event
    def tick(world)
        teacher = participants.find{|x| x.class == Scholar}
        pupils = participants.select{|x| x.is_a? Prince}
        player = participants.find{|x| x.class == Player}

        if teacher.nil?
            pupils.each do |actor|
                actor.tell "Well, I guess the lesson can't continue if there's no one here to teach us."
                actor.leave_event(self)
            end
            return
        end

        if pupils.empty?
            teacher.leave_event(self)
            return
        end

        pupils.each do |actor|
            actor.tell "#{teacher.name} teaches me how to read and write better."
            actor.writing_skill += 1
        end
    end
end
