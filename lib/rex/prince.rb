require 'active_support/core_ext/class/attribute'

module Prince
    TUNIC_COLORS = [
        COLOR_RED = :red, # Primus
        COLOR_WHITE = :white, # Secundus
        COLOR_BLACK = :black, # Tertius
        COLOR_PURPLE = :purple, # Quartus
        COLOR_BLUE = :blue, # Septimus
        COLOR_BROWN = :brown, # Octavius
        NO_TUNIC = :none
    ]

    def self.included(cls)
        cls.instance_eval do |cls|
            attr_accessor :tunic_color
            class_attribute :starting_tunic_color
        end
    end

    def tunic_color=(value)
        if TUNIC_COLORS === value
            @tunic_color = value
        else
            raise ArgumentError "#{value} is not a valid tunic color."
        end
    end
end
