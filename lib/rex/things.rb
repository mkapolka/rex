require_relative 'thing.rb'
require_relative 'person.rb'
require_relative 'carryable.rb'

class Throne < Thing
    self.name = "a golden throne"
    self.description = "This throne glitters in the sunlight."

    parseable_action 'sit', :self do |actor|
        puts "You sit on the throne"
    end
end

class Player < Person
    self.name = "yourself"

    def tell(string)
        puts string
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
        user.player.tell "You see here...\n\t#{things_description}"
    end
end

class Apple < Thing
    include Carryable

    self.name = "an apple"
    self.description = "It's shiny and red."

    def eat(eater)
        eater.tell "You eat #{self.name}."
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

class WetNurse < Person
    self.name = "your wet nurse"
    self.description = "She's responsible for your safety"

    def initialize
        super
        apple = Apple.new
        apple.move(self.location)
        self.take_thing Apple.new
    end

    def move(where)
        old_location = self.location
        self.tell_others "#{self.name} moves to #{where.title}"
        super
        self.tell_others "#{self.name.capitalize} comes in from #{old_location.title.downcase}" unless old_location.nil?
    end

    def tick
        exits = self.location.exits
        self.move(exits[0].room)
    end

    def item_stolen(item, by_whom)
        self.tell_others "#{self.name.capitalize} says 'Hey, give that #{item.name} back!'"
    end

    parseable_action 'talk', :self do |actor|
        actor.tell "#{self.name.capitalize} tells you to remember to wash behind your ears!"
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
