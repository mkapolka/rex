$: << File.dirname(__FILE__)

require 'require_all'
require 'rex/world.rb'
require 'rex/parser.rb'

world = World.new
player = world.player
parser = Parser.new(world, player)
player.look
parser.start
