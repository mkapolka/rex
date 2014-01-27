require_relative 'thing.rb'

class Throne < Thing
    self.name = "a golden throne"

    parseable_action 'sit', :self do |actor|
        puts "You sit on the throne"
    end
end

class Player < Thing
    self.name = "The player"

    parseable_action 'look' do
        names = self.location.contents.map(&:name)
        puts "\n#{location.title}\n#{location.description}"
        things_description = names.join("\n\t")
        puts "You see here...\n\t#{things_description}"
    end
end
