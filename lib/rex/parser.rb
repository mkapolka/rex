require_relative 'action.rb'

class Parser
    QUIT_KEYWORDS = ["quit", "exit", "end game"]
    IRB_KEYWORD = "irb"

    def nearby
        return self.player.location.contents
    end

    def prompt(player, world)
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
                prompt_go(player, world)
            when 'l'
                prompt_look(player, world)
            when 'd'
                acted = prompt_do(player, world)
            when 'w'
                acted = true
                player.tell "I'll wait here a moment."
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

    def prompt_go(player, world)
        rooms = world.locations
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
                    if chosen_room == player.location
                        puts "I'm already there!"
                    else
                        puts "I walk to #{chosen_room.title}."
                        player.move(chosen_room)
                        self.describe_room(player, world, chosen_room)
                        success = true
                        return true
                    end
                end
            end
        end
    end

    def prompt_look(player, world)
        nearby = player.location.contents
        strings = nearby.each_with_index.map{|thing, i| "\n\t[#{i+1}]: #{thing.name}"}
        strings << "\n\t[a]round"
        strings << "\n\t[n]evermind"
        while true
            puts "What should I look at?"
            puts strings.join

            choice = gets.chomp
            if choice == 'n'
                return
            elsif choice == 'a'
                return
            elsif
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

    def prompt_do(player, world)
        actions = []
        # Get actions from current location
        actions += player.location.actions
        player.location.contents.each do |thing|
            actions += thing.actions if thing.respond_to? :actions
        end

        # Get actions from nearby events
        nearby_events = world.events_in(player.location)
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
                    return chosen_action.do(player) unless chosen_action.nil?
                end
            end
        else
            puts "There's nothing to do here."
        end
    end

    def describe_room(player, world, room)
        player.tell "#{room.title}\n#{room.description}"

        # Events should describe what people are doing
        events = world.events_in(room)
        event_descriptions = events.map(&:describe).join("\n")
        people_in_events = events.map(&:participants).flatten.uniq

        # Things and people not in events
        things = room.contents - [player]
        ignored = things.each.reduce [] do |memo, obj|
            memo << obj.holding if obj.respond_to? :holding
            memo += obj.wearing if obj.respond_to? :wearing
            memo
        end
        other_people = (things - ignored - people_in_events).select{|x| x.is_a? Person}
        people_names = other_people.map(&:name).to_sentence + " are here, just standing around."
        other_things = (things - ignored - people_in_events - other_people)
        
        if events.length > 0
            player.tell "#{event_descriptions}\n"
        end
        if other_people.length > 0
            player.tell "#{people_names}\n"
        end
        if other_things.length > 0
            other_names = other_things.map(&:name).to_sentence
            player.tell "#{other_names}"
        end
    end
end

class QuitException < Exception
end

def choose(message, options)
    #Options = dict of key => printed string
    while true
        puts message
        puts options.values.join("\n")
        response = gets.chomp
        if options.keys.index(response)
            return response
        else
            puts "That's not an option."
        end
    end
end
