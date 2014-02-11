require_relative 'room.rb'
require_relative 'things.rb'

class ThroneRoom < Room
    self.description = "The room is suffused with bright sunlight."
    self.title = "The Throne Room"
    self.contents = [
        Throne, Crown
    ]

    exit 'south', :Foyer
end

class Foyer < Room
    self.description = "This room leads to the throne room through an exit to the north."
    self.title = "The Foyer"
    self.contents = [
        WetNurse, Apple, Hood
    ]

    exit 'north', :ThroneRoom
    exit 'east', :Kitchen
end

class Kitchen < Room
    self.description = "Cured meats are hanging from the ceiling."
    self.title = "The Kitchen"
    self.contents = [
        Apple, Stove
    ]
end
