require 'rex/world'
require 'rex/directors/all'

class Game
    attr_accessor :directors, :world

    def initialize
        self.world = World.new
        self.directors = [
            KingDirector.new(world),
            PlayerDirector.new(world)
        ]
    end

    def run
        continue = true
        while continue
            self.world.advance_time
            self.directors.each do |director|
                begin
                    director.tick
                rescue QuitException
                    continue = false
                rescue StandardError
                    puts $!, $@    
                end
            end

            self.world.events.each do |event|
                begin
                    event.tick
                rescue StandardError
                    puts $!, $@
                end
            end
        end
    end
end
