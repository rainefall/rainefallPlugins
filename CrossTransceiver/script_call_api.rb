module CrossTransceiver
    @contacts = {}
    @calls = {}

    def self.get_contacts
        return @contacts
    end

    def self.get_call(call_id)
        return @calls[call_id]
    end

    class Contact
        attr_reader :display_name
        attr_reader :get_conversation_proc
        attr_reader :contact_list_proc

        def initialize(id, &block)
            instance_eval(&block)
        end

        def name(val)
            @display_name = val
        end

        def get_conversation(&block)
            @get_conversation_proc = block
        end

        def contact_list_check(&block)
            @contact_list_proc = block
        end
    end

    class Caller
        attr_reader :name
        attr_reader :character_sprite
        attr_reader :background_sprite

        def initialize(name, character_sprite, background_sprite)
            @name = name
            @character_sprite = character_sprite
            @background_sprite = background_sprite
        end
    end

    class Call
        attr_reader :callers
        attr_reader :conversation_proc

        def initialize(id, &block)
            @callers = []
            instance_eval(&block)
        end

        def add_caller(name, graphic, background)
            @callers << Caller.new(name, graphic, background)
        end

        def conversation(&block)
            @conversation_proc = block
        end
    end

    def self.register_contact(id, &block)
        @contacts[id] = Contact.new(id, &block)
    end

    def self.register_call(id, &block)
        @calls[id] = Call.new(id, &block)
    end

    # This class is used to run your call scripts on the CrossTransceiver scene
    # It exists mainly to simplify the process of writing calls
    # However, if you want to manually manipulate the scene (this is not recommended)
    # you can manually call scene methods on @scene within the conversation block
    class Interface
        def initialize(scene)
            @scene = scene
        end

        def call(block)
            instance_eval(&block)
        end

#==============================================================================
# wait - Waits for specified number of seconds
# Arguments:
#   waitseconds  - Number of seconds to wait
#==============================================================================
        def wait(waitseconds)
            starttime = System.uptime
            until (System.uptime - starttime) >= waitseconds
                @scene.miniupdate
                Graphics.update
            end
        end

#==============================================================================
# show_text - Shows a message and optionally a choices box
# Arguments:
#   caller   - [Integer] Index of the caller who is saying this message
#   text     - [String] Contents of the message
#   &block   - [Block] A block used to set up branching dialogue.
#==============================================================================
        def show_text(caller, text)
            @commands = nil
            @command_branches = nil
            # register dialogue choices
            yield(self) if block_given?
            # display
            @scene.set_active_speaker(caller)
            if @command_branches
                choice = @scene.message_with_branch(text, @commands)
            else
                @scene.message(text)
            end
            @scene.set_no_speaker
            instance_eval(&@command_branches[choice]) if @command_branches
        end

#==============================================================================
# branch_option - Creates a choice and an associated dialogue branch
# Arguments:
#   text     - [String] This option's text to be displayed in the player choice box
#   &block   - [Block] Identical to the block argument for `conversation`
#==============================================================================
        def branch_option(text, &block)
            @commands = [] if !@commands
            @command_branches = [] if !@command_branches
            @commands << text
            @command_branches << block
        end

#==============================================================================
# call_active? - Determine whether or not the call is active
# Returns - [Boolean] Whether or not the call is active
#==============================================================================
        def call_active?
            return @scene.call_active
        end
        
        def end_call
            @scene.call_active = false
        end
    end
end

# Simple linear dialogue example
CrossTransceiver.register_call(:example) {
    add_caller "Juniper", "juniper", "indoor1" # caller 0
    # player is always the last caller, so caller 1 in this case
    # though the player doesnt speak in this example
    conversation { 
        # show text takes two arguments
        # the first argument is the caller index
        # the second argument is the contents of the message
        # you can use most text formatting options that are available in regular textboxes
        show_text(0, "There is a spider (<fs=18>spider,</fs> <fs=12>spider</fs>)")
        show_text(0, "Deep in my soul (soul, soul)")
        show_text(0, "He's lived here for years (years, years)")
        show_text(0, "He just won't let go (go, go)")
    }
}

CrossTransceiver.register_call(:example_4) {
    add_caller "Juniper", "juniper", "indoor1" # caller 0
    add_caller "Rosa", "POKEMONTRAINER_leaf", "field" # caller 1
    # again, player is always the last caller, so caller 2 in this case
    # and again again, the player doesnt speak in this example
    conversation {
        show_text(0, "This is a call with... TWO callers!")
        # `wait` takes one argument, the number of seconds to wait
        wait(2)
        show_text(1, "I can speak without my mouth moving.")
    }
}

# Multiple choice dialogue example
# Ideal for setting up conversations with registered contacts
# Since everything is procs you can put pretty complex logic inside these to determine what messages/branches to display/register
# and in theory it should all work out
CrossTransceiver.register_call(:example_br) {
    add_caller "Juniper", "juniper", "indoor1" # caller 0
    # i'm sure you can tell me what caller the player is by this point
    conversation {
        # we can use variables in dialogue scripts
        has_said_option_1 = false
        has_said_option_2 = false
        while call_active?()
            # `show_text` can accept a block as an argument
            # this should be used exclusively for setting up branches (as it is called before the message is displayed)
            show_text(0, "This is an example of a branching conversation") {
                # A branch is set up by calling `branch_option` followed by
                # player dialogue to be shown in command window, a block containing the contents of that branch
                branch_option("A branching conversation?") {
                    # this block is structurally identical to the root block of a conversation
                    # you do not need to write anything differently in here
                    show_text(0, "Yeah.")
                    has_said_option_1 = true
                }
                branch_option("What?") {
                    show_text(0, "I can't write dialogue to save my life I'm sorry!")
                    has_said_option_2 = true
                }
                branch_option("I'm leaving.") {
                    show_text(0, "Okay, that was always allowed.")
                    # this breaks out of the loop
                    end_call()
                } if has_said_option_1 && has_said_option_2
            }
            # as a result of the while loop, this conversation will loop indefinitely until the player chooses the "I'm leaving" option
            # of course, you can use the power of Ruby to shape your conversation paths however you want
            # maybe you could have it so that the conversation automatically ends once you read every option?
            # the possibilities are ENdLeSs
        end
    }
}

# Example contact
CrossTransceiver.register_contact(:juniper_contact_example) {
    name "Juniper"
    # here we define how the game will determine whether or not to display the contact in the contacts list
    contact_list_check {
        # remember that `return` does not work properly from within blocks, use `next` !
        next true
        # for this example we have the contact always available simply by always returning `true`
        # however i'm certain you will not want every contact in your game available from the start
        # for example:
        next $game_switches[110]
        # would ensure the contact is only visible while switch 110 is set to ON
    }
    # here we define how the game will determine what call to play when the contact is selected in the main xtransceiver menu
    get_conversation {
        # simply return the unique :symbol for the conversation you want to play when the player manually calls this contact
        # chances are you may want the conversation to be different to reflect the progressing story of your game
        # so you can use conditionals to determine which symbol to return
        # typically i would write them like this
        next :example_br if $game_switches[111]
        # but you can do them like this too
        if $game_switches[111]
            next :example_br
        end
        # you should ALWAYS have a return with no conditions attached to it as a fallback
        # just in case
        next :example
        # this will not run if any of the above conditions are met and the `next`s associated with them are run 
        # as `next` exits a block like this as soon as it is called
    }
    # typically you would use game switches/variables to determine both these things, accessed using $game_switches[index] and $game_variables[index] respectfully
}


# Because of "essentials plugin manager things", if you are using the plugin manager version of this script you either have to add all your conversations
# and contacts to THIS FILE or you have to be 100% certain that you know your calls to the CrossTransceiver API will not occur before PluginManager.runPlugins is called
# If you are not using the plugin manager (I salute you) this does not apply, you can register your conversations and contacts in any script section/file
# that appears below this one