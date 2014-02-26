module Carryable
    attr_accessor :held_by

    def self.included(cls)
        cls.parseable_action 'take',:self do |actor|
            actor.take_thing(self)
        end

        cls.parseable_action 'drop', :self do |actor|
            actor.drop_thing(self)
        end

        cls.parser_command 'put', :self do |user|
            nearby_containers = self.location.contents.select{|thing| thing.is_a? Container}
            if nearby_containers.empty? then
                user.player.tell "There's nowhere to put that!"
            else
                container_names = nearby_containers.map {|thing| "\n\tin #{thing.name}"}
                string = "Where should I put #{self.name}? I could put it..."
                string += container_names.join("")
                user.player.tell string
                print ">"
                choice = user.match_noun user.prompt
                unless choice.nil?
                    choice.add(self, user.player) unless choice.nil?
                    user.player.tell "I put #{self.name} into #{choice.name}"
                    user.acted = true
                else
                    user.player.tell "I don't see that here."
                end
            end
        end
    end

    def held_by=(thing)
        @held_by.unhold self if @held_by.respond_to? :unhold
        @held_by = thing
    end
end
