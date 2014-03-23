$: << File.dirname(__FILE__)

require 'require_all'
require 'rex/world.rb'
require 'rex/parser.rb'

world = World.new

continue = true
begin
    while continue
        world.tick
    end
rescue QuitException
    continue = false
rescue Exception
    puts $!, $@
end 
