module MUD
  class Context
    def initialize(options)
      @observer = options[:observer]
      @subject  = options[:subject]
      @target   = options[:target]
      @verb     = options[:verb]
    end

    def subject
      if @observer == @subject
        "you"
      else
        name_of @subject
      end
    end

    def target
      if @subject == @target && @subject == @observer
        "yourself"
      elsif @subject == @target
        "#{pronoun_for @target}self"
      elsif @observer == @target
        "you"
      else
        name_of @target
      end
    end

    def verb
      if @observer == @subject
         @verb
      else
         "#{@verb}s"
      end
    end

    def pronoun_for(player)
      if not @observer.can_see? player
        "it"
      elsif @observer.berserk?
        "it"
      else
        player.objpronoun
      end
    end

    def name_of(player)
      if not @observer.can_see? player
        "someone"
      elsif @observer.berserk?
        "your foe"
      else
        player.name
      end
    end
  end
end
