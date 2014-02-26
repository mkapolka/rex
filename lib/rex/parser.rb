require_relative './parser_command.rb'

class Parser
    QUIT_KEYWORDS = ["quit", "exit", "end game"]
    IRB_KEYWORD = "irb"

    attr_accessor :world, :player, :continue, :user, :nearby

    def initialize(world, player)
        self.world = world
        self.player = player
        self.user = User.new player
    end

    def nearby
        return self.player.location.contents
    end

    def stop
        continue = false
    end

    def start
        continue = true
        while continue
            begin
                continue = do_loop
            rescue
                puts $!, $@
            end
        end
    end

    def do_loop
        print "Do what now?> "
        input = gets.chomp        
        case input.downcase
        when *QUIT_KEYWORDS
            return false
        when IRB_KEYWORD
            require 'ripl'
            puts "Entering IRB mode"
            Ripl.start :binding => binding
            puts "Leaving IRB mode"
        else
            parse input
        end

        if user.acted
            world.tick
            user.acted = false
        end

        return true
    end

    def parse(string)
        # Find potential actions
        parts = string.split
        verb = parts[0]
        direct_object = parts[1]
        preposition = parts[2]
        indirect_object = parts[3]

        #actions_hash = potential_actions.select{|a| a.name == verb and a.compare_direct_object direct_object}
        
        potential_responders = []
        potential_responders.concat self.user.location.contents
        potential_responders << self.user.location
        potential_responders << self.user.player.holding unless self.user.player.holding.nil?
        potential_responders.select! {|thing| thing.can_respond_to(verb, user, direct_object, preposition, indirect_object)}

        if potential_responders.length > 0
            responder = potential_responders[0]
            responder.call_parser_command(verb, user, direct_object, preposition, indirect_object)
        else
            puts "You want to #{verb} the #{direct_object} #{preposition} the #{indirect_object}?"
            return false
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

    def match_noun(name, isnt=nil)
        self.location.contents.find {|x| /#{name}/ =~ x.name && x != isnt}
    end

    def prompt
        return gets.chomp
    end
end
