require_relative 'thing.rb'
require_relative 'person.rb'
require_relative 'carryable.rb'
require_relative 'container.rb'
require_relative 'npc.rb'

class Throne < Thing
    self.name = "a golden throne"
    self.description = "This throne glitters in the sunlight."

    parseable_action 'sit', :self do |actor|
        puts "I sit on the throne"
    end
end

class Player < Person
    self.name = "me"

    def tell(string)
        puts string
        puts ""
    end

    #parseable_action 'look', :none do |me|
    parser_command 'look', :none do |user|
        user.player.tell "#{location.title}\n#{location.description}"
        things = self.location.contents
        ignored = things.each.reduce [] do |memo, obj|
            memo << obj.holding if obj.respond_to? :holding
            memo += obj.wearing if obj.respond_to? :wearing
            memo
        end
        names = (things - ignored).map(&:name)
        things_description = names.join("\n\t")
        user.player.tell "I see here...\n\t#{things_description}"
        exit_strings = user.player.location.exits.map do |exit|
            "#{exit.direction} to get to #{exit.room.title.downcase}"
        end
        user.player.tell "I could go...\n\t#{exit_strings.join("\n\t")}"
    end

    parseable_action 'wait', :none do |actor|
        actor.tell "I wait for a moment."
    end
end

class Clothing < Thing
    class_attribute :slot
    attr_accessor :worn_by

    parseable_action "wear", :self do |actor|
        actor.wear self
    end

    parseable_action "remove", :self do |actor|
        actor.remove_clothing self
    end
end

class Crown < Clothing
    include Carryable

    slot = "Head"

    self.name = "A sparkling crown"
    self.description = "He who wears it commands the kingdom."
end

class Hood < Clothing
    include Carryable

    slot = "Head"

    self.name = "a darkly colored hood"
    self.description = "This will hide my identity."
end

class Stove < Container
    attr_accessor :lit

    self.name = "an iron cauldron suspended over a fire pit"

    def initialize
        super
        self.lit = false
    end

    def description
        base = super
        base = "The cook uses this to make stews."
        base += " The fire underneath is lit. The water in the cauldron is bubbling away." if self.lit
        base += "\n#{self.describe_contents}"
        return base
    end
    
    def tick
        super
        self.contents.each do |thing|
            thing.cook if thing.respond_to? :cook
        end
    end

    def report_add(actor, thing)
        if thing.class == SucklingPig
            actor.tell "I hoist #{thing.name} onto the spit."
            actor.tell_others "#{actor.name} hoists #{thing.name} onto the spit."
        else
            actor.tell "I throw #{thing.name} into the cauldron."
            actor.tell_others "#{actor.name} throws the #{thing.name} into the cauldron."
        end
    end

    def report_remove(actor, thing)
        if thing.class == SucklingPig
            actor.tell "I remove #{thing.name} from the spit."
            actor.tell_others "#{actor.name} removes #{thing.name} from the spit."
        else
            actor.tell "I pull #{thing.name} out of the cauldron."
            actor.tell_others "#{actor.name} pulls #{thing.name} out of the cauldron."
        end
    end

    def light(actor)
        actor.tell "I light fire pit beneath the cauldron."
        actor.tell_others "#{actor.name} lights the fire pit beneath the cauldron"
        self.lit = true
    end

    parseable_action 'light', :self do |actor|
        self.light(actor)
    end
end

class Food < Thing
    include Carryable

    attr_accessor :cooked, :heat_counter
    class_attribute :uncooked_name, :cooked_name, :cooking_time
    self.cooking_time = 1

    def initialize
        self.cooked = false
        self.heat_counter = 0
    end

    def name
        return self.uncooked_name unless self.cooked
        return self.cooked_name
    end

    def cook
        self.heat_counter += 1
        if self.heat_counter >= self.cooking_time
            self.cooked = true
            self.tell_others "#{self.name} smells delicious!"
        else
            self.tell_others "#{self.name} sizzles and pops."
        end
    end

    def eat(eater)
        eater.tell "I eat #{self.name}."
        eater.tell_others "#{eater.name} eats the apple."
        if self.held_by then
            self.held_by.holding = nil
        end
        self.destroy
    end

    parser_command 'eat', :self do |user|
        self.eat(user.player)
        user.acted = true
    end
end

class SucklingPig < Food
    self.uncooked_name = "an uncooked suckling pig"
    self.cooked_name = "a cooked suckling pig"
    self.cooking_time = 5

    self.description = "That thing is as big as me. I'd rather not look at it anymore."
end

class Apple < Food
    self.uncooked_name = "an apple"
    self.cooked_name = "a baked apple"
    self.description = "It's shiny and red."

    self.cooking_time = 3
end
