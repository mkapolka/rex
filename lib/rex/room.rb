require_relative 'actions.rb'
require 'active_support/core_ext/class/attribute'

class Room
    include ActionContainer

    class_attribute :actions, :description, :name, :exits, :initial_contents
    attr_accessor :contents

    def initialize
        self.contents = []
    end
end
