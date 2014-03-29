require_relative 'prince.rb'
require_relative 'person.rb'

class Player < Person
    include Prince

    self.name = "me"

    self.starting_tunic_color = COLOR_BLUE

    def tell(string)
        puts string
        puts ""
    end
end
