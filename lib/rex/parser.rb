class Parser
    QUIT_KEYWORDS = ["quit", "exit", "end game"]

    attr_accessor :world, :player, :continue

    def initialize(world, player)
        self.world = world
        self.player = player
    end

    def stop
        continue = false
    end

    def start
        continue = true
        while continue
            continue = do_loop
        end
    end

    def do_loop
        print "Do what now?> "
        input = gets.chomp        
        if QUIT_KEYWORDS.include? input.downcase
            return false
        end

        parse input
        world.tick


        return true
    end

    def potential_actions
        # Player actions
        actions = []
        self.player.location.contents.each do |thing|
            actions += thing.actions
        end
        #actions += self.player.location.class.actions
    end

    def parse(string)
        # Find potential actions
        parts = string.split
        verb = parts[0]
        direct_object = parts[1]
        preposition = parts[2]
        indirect_object = parts[3]

        if potential_actions.include? verb
            potential_actions[verb].call(direct_object, preposition, indirect_object)
        else
            p "You want to #{verb} the #{direct_object} #{preposition} the #{indirect_object}???"
            return false
        end
    end
end
