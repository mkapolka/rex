require_relative 'actions.rb'
require_relative 'parser_command.rb'

module ParseableAction
    def self.extended(cls)
        cls.send(:include, ActionContainer)
        cls.send(:include, Parseable)
    end

    def parseable_action(name, direct_object=ParserCommand::DIROBJ_NONE, preposition=nil, indirect_object=ParserCommand::DIROBJ_NONE, &method)
        self.action(name, &method)

        mapped_proc = lambda do |user, direct_object, preposition, indirect_object|
            direct_object_thing = user.match_noun(direct_object)
            indirect_object_thing = user.match_noun(indirect_object, isnt: direct_object)
            self.call_action(name, user.player, direct_object, indirect_object)
            user.acted = true
        end

        self.parser_command(name, direct_object, preposition, indirect_object, &mapped_proc)
    end
end
