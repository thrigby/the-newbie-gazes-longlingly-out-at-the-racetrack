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
        "You"
      else
        name_of(@subject).capitalize
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
    
    def pospronoun
      if @subject != @observer
          @subject.pospronoun
       else
         "your"
       end
     end
     
    def isare
      if @subject != @observer
        "is"
      else
        "are"
      end        
    end
    
    def tisare
      if @subject != @observer
        "are"
      else
        "is"
      end
    end
     
    def tarverb
      if @observer == @subject
      "#{@verb}s"
      else
      @verb
      end
    end
    
    def verbes
      if @observer == @subject
      @verb
      else
      "#{@verb}es"
      end
    end
    
    def tarverbes
      if @observer == @subject
      "#{@verb}es"
      else
      @verb
      end
    end

    def verb
      if @observer == @subject
         @verb
      else
         "#{@verb}s"  #if it's just the squigileedoo "#{verb}" verb will suffice!!! the lilly pad instead of addition.
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
    
    def to_s
      self.subject
    end
  
          
    def method_missing(method, *args)
      if method.to_s =~ /^(.+)\!$/
        verb = $1
        if @observer == @subject
          verb
        else
          "#{verb}s"
        end
      else
        super method, *args
      end
    end
  end
end


