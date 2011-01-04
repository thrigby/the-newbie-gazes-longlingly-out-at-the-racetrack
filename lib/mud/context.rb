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
     
    def tarpospronoun
      if @subject != @observer
        "your"
      else
        @subject.pospronoun
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

=begin
^ beginning of a line (optional)
$ end of a line (necessary)
(only match this is it matches the full line. looking for something that ENDS with an exclamation point.)
bang is slang for exclamation point!
\ prepend to say, look for actual character rather than the special symbol it represents... thus \!
oh wait... the backslash is unnecessary because ! isn't a special character. thus ^ and $ are unnecessary in this particular example.
. means any character.
+ means, one or more of whatever character is to the left of me.
x+ would mean, match one or more x's
.+ means one or more character, followed by a bang, followed by an end of line.
( ) hey, if this matches, take whatever is in here and shove it into the $1. if multiple parantheticals, $1, $2...

give me a string that starts with one more more characters, followed by an exclamation point, followed by an end of line, and then shove it into $1.

 /(.+)!$/ 
 is the concise version!
 
setting up the alias of verb is just giving $1 a nice description. more descriptive coding.
=end  
          
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


