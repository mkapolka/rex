require_relative 'thing.rb'

class Container < Thing
    attr_accessor :contents
    def initialize
        super
        self.contents = []
    end

    def describe
        str = super
        str += "\n"
        if self.contents.length > 0 then
            str += "It contains..."
            str += self.contents.map(&:name).join("\n\t")
        else
            str += "It is empty."
        end
    end

    def report_add(actor, thing)
        actor.tell "I put #{thing.name} into #{self.name}."
        actor.tell_others "#{actor.name} puts #{thing.name} into #{self.name}"
    end

    def report_remove(actor, thing)
        actor.tell "I remove the #{thing.name} from the #{self.name}"
        actor.tell_others "#{actor.name} takes #{thing.name} from #{self.name}"
    end

    def add(thing, actor=nil)
        self.report_add(actor) unless actor.nil?
        self.contents << thing
    end

    def remove(thing, actor=nil)
        if self.contents.index(thing) > 0 then
            self.report_remove(actor) unless actor.nil?
            self.contents.delete(thing)
        end
    end
end
