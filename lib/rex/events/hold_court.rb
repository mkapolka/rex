require 'rex/event'
require 'rex/npcs/king'
require 'rex/places'

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
