class ParserCommand
    DIROBJ_SELF = :self
    DIROBJ_ANY = :any
    DIROBJ_NONE = :none

    INDIROBJ_NONE = :none
    INDIROBJ_ANY = :any

    attr_accessor :name, :direct_object, :preposition, :indirect_object, :function

    def initialize(name, direct_object, preposition, indirect_object, &function)
        self.name = name
        self.direct_object = direct_object
        self.preposition = preposition
        self.indirect_object = indirect_object
        self.function = function
    end
end

module Parseable
    module ClassMethods
        def self.extended(cls)
            cls.class_attribute :parser_commands
            cls.parser_commands = {}
        end

        def parser_command(name, direct_object=DIROBJ_NONE, preposition=nil, indirect_object=INDIROBJ_NONE, &function)
            self.parser_commands = self.parser_commands.dup
            command = ParserCommand.new(name, direct_object, preposition, indirect_object, &function)
            self.parser_commands[name] = command
        end
    end

    def self.included(cls)
        cls.extend ClassMethods
    end

    def call_parser_command(command_name, *args)
        instance_exec(*args, &self.parser_commands[command_name].function)
    end
end
