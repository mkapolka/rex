require_relative 'prince.rb'
require_relative 'person.rb'
require_relative 'parser.rb'

class Player < Person
    include Prince

    attr_accessor :parser

    self.name = "me"

    self.starting_tunic_color = COLOR_BLUE

    def initialize
        super
        self.parser = Parser.new self
    end

    def tell(string)
        puts string
        puts ""
    end

    def tick
        super
        self.parser.prompt
    end

    def look
        self.tell "#{location.title}\n#{location.description}"
        things = self.location.contents
        ignored = things.each.reduce [] do |memo, obj|
            memo << obj.holding if obj.respond_to? :holding
            memo += obj.wearing if obj.respond_to? :wearing
            memo
        end
        names = (things - ignored).map(&:name)
        things_description = names.join("\n\t")
        self.tell "I see here...\n\t#{things_description}"
    end
end
