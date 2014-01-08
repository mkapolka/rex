require 'active_support/core_ext/class/attribute'

module ActionContainer
    attr_accessor :actions

    # name: Any string
    # direct object: :self or :none
    # preposition: Any string (should really be a preposition though)
    # indirect object: :self, :any, or :none
    def self.action(name, direct_object, preposition, indirect_object)
        self.actions += {
            name: name,
            direct_object: direct_object,
            preposition: preposition,
            indirect_object: indirect_object
        }
    end
end
