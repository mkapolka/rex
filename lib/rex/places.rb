require_relative 'room.rb'
require_relative 'things.rb'
require_relative 'npcs.rb'

class ThroneRoom < Room
    self.description = "The room is suffused with bright sunlight."
    self.title = "The Throne Room"
    self.contents = [
        Throne, King
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
    exit 'south', :Courtyard
    exit 'west', :DiningRoom
    exit 'east', :Hallway
end

class Kitchen < Room
    self.description = "Cured meats are hanging from the ceiling."
    self.title = "The Kitchen"
    self.contents = [
        Apple, Stove
    ]

    exit 'east', :DiningRoom
end

class DiningRoom < Room
    self.description = "The nearer you are to the head of the table the more important you are."
    self.title = "The Dining Room"
    self.contents = []

    exit 'east', :Foyer
    exit 'west', :Kitchen
end

class Hallway < Room
    self.description = "This hallway separates the living quarters from the royal sleeping quarters."
    self.title = "The Hallway"
    self.contents = []

    exit 'west', :Foyer
    exit 'east', :PrinceAnnex
    exit 'north', :RoyalBedroom
end

class RoyalBedroom < Room
    self.description = "The King and Queen's Royal Bedchambers."
    self.title = "The Royal Bedroom"

    exit 'south', :Hallway
end

class PrinceAnnex < Room
    self.description = "A hastily built addition to the castle made to link the sudden princes' rooms."
    self.title = "The Princes' Annex"

    exit 'west', :Hallway
    exit 'north', :MyRoom
    exit 'east', :OctaviusRoom
end

class MyRoom < Room
    self.description = "This is my room. Here, at least, I can expect some privacy."
    self.title = "My Room"
    self.contents = [
        Maid
    ]

    exit 'south', :PrinceAnnex
end

class OctaviusRoom < Room
    self.description = "This is Octavius' room. It's a pigsty."
    self.title = "Octavius' Room"

    exit 'west', :PrinceAnnex
end

class Courtyard < Room
    self.description = "It's a beautiful day out here. A perfect day for patrilineage!" 
    self.title = "The Courtyard"

    self.contents = []

    exit 'north', :Foyer
    exit 'west', :Stables
end

class Stables < Room
    self.description = "Smells like horses despite their absence."
    self.title = "The Stables"

    self.contents = []

    exit 'east', :Courtyard
end
