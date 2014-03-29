$: << File.dirname(__FILE__)

require 'require_all'
require 'rex/game'

# Suppress deprecation warning
I18n.enforce_available_locales = false

game = Game.new
game.run
