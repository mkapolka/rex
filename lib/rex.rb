$: << File.dirname(__FILE__)

require 'require_all'
require 'rex/world.rb'
require 'rex/parser.rb'

# Suppress deprecation warning
I18n.enforce_available_locales = false

world = World.new

continue = true

while continue
    begin
        world.tick
    rescue QuitException
        continue = false
    rescue StandardError
        puts $!, $@
    end 
end
