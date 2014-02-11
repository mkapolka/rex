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
            cls.parser_commands = []
        end

        def parser_command(name, direct_object=ParserCommand::DIROBJ_NONE, preposition=nil, indirect_object=ParserCommand::INDIROBJ_NONE, &function)
            self.parser_commands = self.parser_commands.dup
            command = ParserCommand.new(name, direct_object, preposition, indirect_object, &function)
            self.parser_commands << command
        end
    end

    def self.included(cls)
        cls.extend ClassMethods
    end

    def can_respond_to(verb, user, direct_object, preposition, indirect_object)
        return !self.find_command_matching(verb, user, direct_object, preposition, indirect_object).nil?
    end

    def find_command_matching(verb, user, direct_object=nil, preposition=nil, indirect_object=nil)
        options = self.parser_commands.select do |command|
            name_match = (verb == command.name)
            # Match direct object
            case command.direct_object
            when ParserCommand::DIROBJ_SELF
                if direct_object && direct_object.length > 0 then
                    dirobj_match = !(/#{direct_object}/ =~ self.name).nil?
                end
            when ParserCommand::DIROBJ_ANY
                dirobj_match = true
            when ParserCommand::DIROBJ_NONE
                dirobj_match = direct_object.nil?
            end
            # match preposition
            prep_match = preposition == command.preposition

            true if name_match && dirobj_match && prep_match
        end 
        return options[0] if options.length > 0
        return nil
    end

    def call_parser_command(command_name, *args)
        command = self.find_command_matching(command_name, *args)
        instance_exec(*args, &command.function)
    end
end
