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

class Apple < Thing
    include Carryable

    self.name = "an apple"
    self.description = "It's shiny and red."

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

class WetNurse < NPC
    self.name = "my wet nurse"
    self.description = "She's responsible for my safety"

    def initialize
        super
        apple = Apple.new
        apple.move(self.location)
        self.take_thing Apple.new
    end

    def move(where)
        super
    end

    def tick
        super
        wander
    end

    def wander
        old_location = self.location
        where = self.location.exits[0].room
        self.tell_others "#{self.name} moves to #{where.title}"
        self.move(where)
        self.tell_others "#{self.name.capitalize} comes in from #{old_location.title.downcase}" unless old_location.nil?
    end

    def item_stolen(item, by_whom)
        self.tell_others "#{self.name.capitalize} says 'Hey, give that #{item.name} back!'"
    end

    parseable_action 'talk', :self do |actor|
        actor.tell "#{self.name.capitalize} tells me to remember to wash behind my ears!"
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
        base = "The cook uses this to make stews."
        base += " The fire underneath is lit. The water in the cauldron is bubbling away." if self.lit
        return base
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

class King  < NPC
    self.name = "the king"
    self.description = "He rules!"

    def initialize
        super
        crown = Crown.new
        self.wear(crown)
    end

    def tick
    end
end
