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

    parseable_action 'look', :none do |me|
        me.tell "#{location.title}\n#{location.description}"
        things = self.location.contents
        held = things.each.reduce [] do |memo, obj|
            memo << obj.holding if obj.respond_to? :holding
            memo
        end
        names = (things - held).map(&:name)
        things_description = names.join("\n\t")
        me.tell "You see here...\n\t#{things_description}"
    end
end

class Apple < Thing
    include Carryable

    self.name = "an apple"
    self.description = "It's shiny and red."

    parseable_action 'eat', :self do |actor|
        actor.tell "You eat the apple."
    end
end
