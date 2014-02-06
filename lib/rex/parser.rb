require_relative './parser_command.rb'

class Parser
    QUIT_KEYWORDS = ["quit", "exit", "end game"]
    IRB_KEYWORD = "irb"

    attr_accessor :world, :player, :continue, :user

    def initialize(world, player)
        self.world = world
        self.player = player
        self.user = User.new player
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

        world.tick

        return true
    end

    def get_responder(thing, verb, direct_object, preposition, indirect_object) 
        responders = thing.parser_commands.values.select do |command|
            name_match = (verb == command.name)
            # Match direct object
            case command.direct_object
            when ParserCommand::DIROBJ_SELF
                if direct_object && direct_object.length > 0 then
                    dirobj_match = !(/#{direct_object}/ =~ thing.name).nil?
                end
            when ParserCommand::DIROBJ_ANY
                dirobj_match = true
            when ParserCommand::DIROBJ_NONE
                dirobj_match = direct_object.nil?
            end
            # match preposition
            prep_match = preposition == command.preposition

            name_match && dirobj_match && prep_match
        end
        return responders.first()
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
        potential_responders.select! {|thing| get_responder(thing, verb, direct_object, preposition, indirect_object)}

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
    attr_accessor :player

    def initialize(player)
        self.player = player
    end

    def location
        self.player.location
    end

    def match_noun(name, isnt=nil)
        self.location.contents.find {|x| x.name == name unless x == isnt}
    end
end
