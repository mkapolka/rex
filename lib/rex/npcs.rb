require_relative 'npc.rb'
require_relative 'things.rb'
require_relative 'places.rb'

class King < NPC
    self.name = "the king"
    self.description = "He rules!"

    def initialize
        super
        crown = Crown.new
        self.wear(crown)
    end
end

class Maid < NPC
    self.name = "the maid"
    self.description = "Her job is to clean the castle."

    attr_accessor :cleaned_rooms, :state

    def initialize
        super
        self.cleaned_rooms = []
    end

    def tick_state state
        case state
        when CleanState
            if self.location != self.state.target_room
                self.move_towards(state.target_room)
            else
                self.tell_others "#{self.name} cleans some stuff."
            end
        else
            super
        end
    end

    def decide_next_state
        case self.state
        when WaitState
            self.tell_others "#{self.name} thinks about which room to clean next..."
            remaining_rooms = reachable_rooms - self.cleaned_rooms
            next_room = remaining_rooms[0]
            self.tell_others "#{self.name} decides to clean #{next_room.title.downcase}"
            self.state = CleanState.new(next_room)
        end
    end
end

class CleanState < State
    attr_accessor :target_room

    def initialize(target_room)
        self.target_room = target_room
    end
end

class WetNurse < NPC
    self.name = "my wet nurse"
    self.description = "She's responsible for my safety"

    def item_stolen(item, by_whom)
        self.tell_others "#{self.name.capitalize} says 'Hey, give that #{item.name} back!'"
    end

    def tick_state(state)
        case state
        when ScaredState
            self.tell_others "#{self.name.capitalize} shivers with fear."
            self.wait_tick(self.state)
        when WaitState, WanderState
            player = self.location.contents.find do |thing|
                thing.is_a? Player
            end

            unless player.nil?
                self.tell_others "#{self.name.capitalize} says, \"There you are, you little rascal\""
                self.tell_others "Great. Now #{self.name} is following me."
                self.state = FollowState.new(player)
            else
                super
            end
        else
            super
        end
    end

    parseable_action 'talk', :self do |actor|
        actor.tell "#{self.name.capitalize} tells me to remember to wash behind my ears!"
    end

    parseable_action 'scare', :self do |actor|
        actor.tell "I gave #{self.name} a good fright! She's scared stiff!"
        self.state = ScaredState.new(Random::rand(4) + 1)
    end
end

class ScaredState < WaitState
end

class Cook < NPC
    self.name = 'the cook'
    self.description = "She prepares the meals for the castle. "\
                       "She's very strong from hoisting pigs onto the spit."

    def initialize
        super
        self.state = FindIngredientState.new(SucklingPig)
    end

    def tick_state(state)
        case state
        when FindIngredientState
            self.find_ingredient_tick(self.state)
        when PrepareIngredientState
            self.prepare_ingredient_tick(self.state)
        when CookIngredientState
            self.cook_ingredient_tick(self.state)
        when DeliverFoodState
            self.deliver_food_tick(self.state)
        else
            super
        end
    end

    def decide_next_state
        case self.state
        when FindIngredientState
            if self.state.ingredient_matches(self.holding)
                self.state = CookIngredientState.new(self.holding.class)    
            end
        else
            super
        end
    end

    def find_ingredient_tick(state)
        # Search current room
        thing = self.location.contents.find{|t| state.ingredient_matches(t)}
        unless thing.nil?
            self.take_thing(thing)
            self.state = PrepareIngredientState.new(state.ingredient_class)
        end

        state.searched_rooms << self.location

        # Start searching in places where we remember seeing it
        location = self.remember_where_is{|x| state.ingredient_matches(x)}
        unless location.nil? && self.location != location then
            self.move_towards(location)
        else
            # Start searching
            rooms_to_search = [Kitchen, StoreRoom]
            rooms_to_search = self.reachable_rooms - state.searched_rooms
            if rooms_to_search.length > 0
                self.move_towards(rooms_to_search[0])
            else
                # Give up
                puts "DEBUG MESSAGE: #{self.name} couldn't find the ingredient they need!"
            end
        end
    end

    def prepare_ingredient_tick(state)
        # Return to find ingredient state if we lose the item
        if not state.ingredient_matches(self.holding) then
            self.state = FindIngredientState.new(state.ingredient_class)
        end

        if self.location.class != Kitchen then
            self.move_towards(self.find_room(Kitchen))
        else
            # Find the stove
            self.put_thing_into(self.holding, nearby_stove)
            self.state = CookIngredientState.new state.ingredient_class
        end
    end

    def nearby_stove
        self.location.contents.find{|x| x.class == Stove}
    end

    def cook_ingredient_tick(state)
        if nearby_stove.nil?
            self.move_towards(self.find_room(Kitchen))
        end
        # Make sure there's an ingredient in the stove
        ingredient = nearby_stove.contents.find{|x| state.ingredient_matches x}
        if ingredient.nil? then
            state = FindIngredientState.new state.ingredient_class
        else
            if ingredient.cooked then
                self.take_thing(ingredient)
                self.tell_others "#{self.name} says \"Now to take this to the kitchen!\""
                self.state = DeliverFoodState.new(state.ingredient_class, self.find_room(DiningRoom))
            else
                self.tell_others "#{self.name} turns the spit."
            end
        end
    end

    def deliver_food_tick(state)
        # Make sure we're holding ther right food
        unless state.ingredient_matches self.holding and self.holding.cooked
            # Check the current room
            target_food = self.location.contents.find{|x| state.ingredient_matches x and x.respond_to?(:cooked) and x.cooked}
            unless target_food.nil?
                self.take_thing(target_food)
            else
                # Start searching
                location = self.remember_where_is{|x| state.ingredient_matches x && x.respond_to?(:cooked) && x.cooked}
                unless location.nil?
                    self.move_towards(location)
                else
                    # TODO more thorough search
                end
            end
        else
            # We actually have the thing- bring it to the kitchen
            if self.location != state.target_room then
                self.move_towards state.target_room
            else
                self.drop_thing self.holding
                self.decide_next_state
            end
        end
    end
end

class CookingState < State
    attr_accessor :ingredient_class

    def initialize(ingredient_class)
        self.ingredient_class = ingredient_class
    end

    def ingredient_matches(thing)
        return thing.class == self.ingredient_class
    end
end

class FindIngredientState < CookingState
    attr_accessor :searched_rooms, :next_room

    def initialize(ingredient_class)
        super
        self.searched_rooms = []
    end
end

class PrepareIngredientState < CookingState
end

class CookIngredientState < CookingState
end

class DeliverFoodState < CookingState
    attr_accessor :target_room

    def initialize(ingredient_class, target_room)
        super ingredient_class
        self.target_room = target_room
    end
end
