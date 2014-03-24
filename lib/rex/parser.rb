require_relative 'action.rb'

class Parser
    QUIT_KEYWORDS = ["quit", "exit", "end game"]
    IRB_KEYWORD = "irb"

    attr_accessor :player, :continue, :user, :nearby

    def initialize(player)
        self.player = player
        self.user = User.new player
    end

    def nearby
        return self.player.location.contents
    end

    def prompt
        # Returns true if the parser should continue parsing,
        # false if the user wants to quit

        acted = false
        while not acted
            puts "What should I do?"
            puts "[g]o somewhere, [l]ook at something, [d]o something, [w]ait a bit"

            choice = gets.chomp

            puts "=================="

            case choice
            when 'g'
                prompt_go
            when 'l'
                prompt_look
            when 'd'
                acted = prompt_do
            when 'w'
                acted = true
                user.player.tell "I'll wait here a moment."
            when IRB_KEYWORD
                require 'ripl'
                puts "Entering IRB mode"
                Ripl.start :binding => binding
                puts "Leaving IRB mode"
            when *QUIT_KEYWORDS
                raise QuitException.new "Quitting from prompt."
            end
        end
    end

    def prompt_go
        rooms = self.player.location.world.locations
        strings = rooms.each_with_index.map{|location, i| "\n\t[#{i+1}]: #{location.title}"}
        strings << "\n\t[n]evermind"
        while true
            puts "Where should I go?"
            puts strings.join
            choice = gets.chomp
            if choice == 'n'
                return false
            else
                chosen_room = rooms[choice.to_i - 1]
                unless chosen_room.nil?
                    if chosen_room == user.player.location
                        puts "I'm already there!"
                    else
                        puts "I walk to #{chosen_room.title}."
                        user.player.move chosen_room
                        user.player.look
                        success = true
                        return true
                    end
                end
            end
        end
    end

    def prompt_look
        nearby = user.player.location.contents
        strings = nearby.each_with_index.map{|thing, i| "\n\t[#{i+1}]: #{thing.name}"}
        strings << "\n\t[n]evermind"
        while true
            puts "What should I look at?"
            puts strings.join

            choice = gets.chomp
            if choice == 'n'
                return
            else
                chosen_thing = nearby[choice.to_i - 1]
                unless chosen_thing.nil?
                    puts chosen_thing.describe
                    return false
                else
                    puts "That wasn't an option."
                end
            end
        end
    end

    def prompt_do
        actions = []
        # Get actions from current location
        actions += self.player.location.actions
        self.player.location.contents.each do |thing|
            actions += thing.actions if thing.respond_to? :actions
        end

        # Get actions from nearby events
        nearby_events = self.player.location.contents.map{|x| x.event if x.respond_to? :event}
        nearby_events.select! {|x| x}
        nearby_events.uniq!
        nearby_events.each do |event|
            actions += event.actions
        end

        actions.uniq!


        if actions.length > 0
            while true
                puts "What should I do?"
                options = ""
                actions.each_with_index do |action, i|
                    options += "\n[#{i+1}]: #{action.name}"
                end
                options += "\n[n]evermind"
                puts options
                choice = gets.chomp
                if choice == 'n'
                    return false
                else
                    index = choice.to_i
                    chosen_action = actions[choice.to_i-1]
                    return chosen_action.do(self.player) unless chosen_action.nil?
                end
            end
        else
            puts "There's nothing to do here."
        end
    end
end

class User
    # The Thing that the player is controlling
    attr_accessor :player, :acted

    def initialize(player)
        self.player = player
        self.acted = false
    end

    def location
        self.player.location
    end
end

class QuitException < Exception
end
