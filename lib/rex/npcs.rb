require_relative 'npc.rb'
require_relative 'things.rb'
require_relative 'places.rb'

class King < NPC
    self.name = "the king"
    self.description = "He rules!"

    def initialize
        super
        crown = Crown.new
        self.wear(crown)
        e = HoldCourtEvent.new
        self.join(e)
    end

    def tick
        super
        if self.time == World::TIME_EVENING
            self.say "Time for dinner!"
            self.leave_event(self.event)
            self.move self.find_room(DiningRoom)
            self.join_or_start_event(DinnerEvent)
        end
    end
end

class HoldCourtEvent < Event
    def describe
        not_leader = self.participants - [self.leader]
        return "#{self.leader.name} is holding court. #{not_leader.map(&:name).to_sentence} are in attendance."
    end

    def leader
        self.participants.find{|x| x.class == King}
    end

    def tick
        participants.each do |actor|
            # Move the participants to the throne room
            if actor.location.class != ThroneRoom then
                actor.move actor.find_room ThroneRoom
            end
        end

        king = self.leader
        player = participants.find{|x| x.class == Player}

        unless player.nil?
            player.tell "The king holds court. Advice is sought, deals are made. Eventually, the king asks me how I would resolve a conundrum."
            player.tell "A craftsman has taken on an order that he does not think he can complete. Should he:\n"\
                        "a) Admit to his client that he cannot complete the order\n"\
                        "b) Rush to complete the order, potentially sacrificing the quality of his work."
            print ">"
            responded = false
            while !responded
                response = gets.chomp
                case response
                when 'a'
                    player.tell 'The king tells me, "You have the honesty to admit to your limitations. A wise choice."'
                    responded = true
                when 'b'
                    player.tell 'The king tells me, "You are ambitious and tenacious. A wise choice."'
                    responded = true
                end
            end
        end
    end
end

class Cook < NPC
    self.name = 'the cook'
    self.description = "She prepares the meals for the castle. "\
                       "She's very strong from hoisting pigs onto the spit."

    def initialize
        super
        self.event = CookingEvent.new
    end
end

class CookingEvent  < Event
    def tick
        participants.each do |actor|
            if not actor.in_room? Kitchen
                actor.move actor.find_room Kitchen
            else
                messages = [
                    "#{actor.name} turns the spit.",
                    "#{actor.name} chops some onions.",
                    "#{actor.name} slices an apple.",
                    "#{actor.name} grinds up some spices.",
                    "#{actor.name} grills up an onion.",
                    "#{actor.name} throws a potato into the stew."
                ]

                actor.tell_others(messages[rand(messages.length)])
            end
        end
    end
end

class Scholar < NPC
    self.name = "the scholar"
    self.description = "He researches the mysteries of the world."

    def intiialize
        super
        self.event = ResearchEvent.new
    end
end

class ResearchEvent < Event
    def tick
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

class TeachEvent < Event
    def tick
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

class DinnerEvent < Event
    def tick
        self.participants.each {|x| x.tell "Everyone has a really nice meal and nothing interesting happens at all."}
        self.end()
    end
end
