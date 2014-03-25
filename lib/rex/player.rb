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

        # Events should describe what people are doing
        events = self.location.contents.map{|x| x.event if x.respond_to? :event}.compact
        event_descriptions = events.map(&:describe).join("\n")
        people_in_events = events.map(&:participants).flatten.uniq

        # Things and people not in events
        things = self.location.contents - [self]
        ignored = things.each.reduce [] do |memo, obj|
            memo << obj.holding if obj.respond_to? :holding
            memo += obj.wearing if obj.respond_to? :wearing
            memo
        end
        other_people = (things - ignored - people_in_events).select{|x| x.is_a? Person}
        people_names = other_people.map(&:name).to_sentence + "are here, just standing around."
        other_things = (things - ignored - people_in_events - other_people)
        
        self.tell "#{event_descriptions}\n"
        if other_people.length > 0
            self.tell "#{people_names}\n"
        end
        if other_things.length > 0
            other_names = other_things.map(&:name).to_sentence
            self.tell "#{other_names}"
        end
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
end
