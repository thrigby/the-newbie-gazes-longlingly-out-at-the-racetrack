module MUD
  class MissingTarget < RuntimeError; end
  module Commands
    def do_help
      send "                BABY SEAL MUD COMMANDS"
      send "          say: just type say and your message"
      send "         Look: examine your immediate surroundings or other seals."
      send "         exit: leave the game"
      send "         help: what you're looking at right now."
      send "       Bounce: makes magic bubblegum. also how you move."
      send "         Flop: for resting and chewing bubblegum."
      send "          Get: pick up magic bubblegum."
      send "         Chew: prepare for magic! precurser to blow."
      send "         Blow: make powerful tools to aid you!"
      send "         Take: greedy you, you pick up all of the items in the room."
      send "    Inventory: examine your inventory."
      send "         Wear: wear that magic!"
      send "        wield: wield that magic!"
      send "       Remove: un-wear that magic!"
      send "         cold: go out in style"
      send "      socials: flex, spit, smile"
      send "    sexchange: change those personal pronouns"
      send "         kill: kill target."
      send "         Drop: you drop a magic item on the ground."
      send "         glue: glue two objects together. note- if you have three or more objects in your inventory, you'll lose them."
      send " Capitalized commands have shortcuts, the first letter of the command. l for look, w for wear, and so on. note: b = bounce, bb = blow bubble"
      send "\n Score or 'sc' gives you some vague information that will probably not be all that helpful. This game is completely rigged and you really don't stand any sort of chance."
    end

    # orion: seems like you'd want to have these be @blubber instead of @str and @beadiness instead of @dex
    def do_score
      send "             Blubber: #{@str}"
      send "       Eye-Beadiness: #{@dex}"
      send "               Pluck: #{@cool}"
      send "            Cuteness: #{@luck}"
      send "      Whisker Length: #{@wis}"
      send "                                XP: #{@exp}"
    end

    def do_flop
       act(:flop) { |c| "#{c.subject} #{c.verb} on the ground with an adorable little grunt." }
       @position = :flop
    end

    def do_wear                     #set target self? pronoun
      if @inv.empty?
        send "Your inventory is empty."
      else  
        act(:balance) { |c| "#{c.subject} carefully #{c.verb} #{@inv.last} on head." }
        @wear.push(@inv.pop)
      end
    end

    def do_remove                 #set target self? pronoun
      if @wear.empty?
        send "You aren't wearing anything to remove."
      else
        
        act(:remove) { |c| "#{c.subject} #{c.verb} #{@wear.last} from  head."}
        @inv.push(@wear.pop)
      end
    end

    def do_chew
      unless @position == :flop
        send "One cannot chew gum and bounce at the same time."
      return
      end
      if @inventorybg > 0
        act(:chew) { |c| "#{c.subject} #{c.verb} a piece of magical bubblegum."}
        @inventorybg -= 1
        @readytoblow = true
      else
        send "You are all out of gum! Bounce to make more!"
      end
    end

    def do_inventory
      send "you look in your fannypack! you have #{@inventorybg} pieces of bubblegum!"
      if @inv.empty?
        send "You aren't carrying anything."
      else
         send "You are carrying:"
         @inv.each { |m| send "#{m.item}"}
      end

      if @wear.empty?
        send "You aren't wearing anything."
      else
        send "\n You are balancing the following on your head:"
        @wear.each { |m| send "#{m.item}"}
      end
        send "You sense that your attack power is #{@inv.length}"
        send "You sense that your defense is #{@wear.length}"
    end

    # orion: this code has 3 states
    # 1) no target specified
    # 2) target specified but no one there
    # 3) target specified and found
    # since find_player is always called (even if no name is passed) and returns nil if its not found
    # you are going to do "You smile" and never NOBODY HOME

    def do_smile(name)
      # orion: note I can aboid the NOBDY home thing here since it will jump up to the exception handler above
      # also - target.name is a pain to type ... if you have Player#to_s return @name we could just say 'target' here...
      if name
        target = find_player_by_name!(name)
        act(:smile, target) { |c| "#{c.subject} #{c.verb} at #{c.target}." }
      else
        act(:smile) { |c| "#{c.subject} #{c.verb}." }
      end
    end

    def do_cold_eye(target)
        target = find_player_by_name(target)
        if target == nil
          send "You gaze at the horizon and calmly thumb shells into your blue-steel shotgun."
          other_players.each { |p| p.send "#{name} gazes at the horizon and calmly thumb shells into #{pospronoun} blue-steel shotgun."}
        else
          if target
            if target.name.downcase == name.downcase
              send "You thumb shells into your blue-steel shotgun and put it in your mouth."
              other_players.each { |p| p.send "#{name} thumbs shells into his blue-steel shotgun and puts it in #{pospronoun} mouth."}
              EventMachine::Timer.new(2) do
                send "You pull the trigger and BLAM! Baby Seal brains EVERYWHERE! Nooooo!"
                other_players.each { |p| p.send "#{name} pulls the trigger and BLAM!\n#{pospronoun} Baby Seal brains go everywhere!" }
                EventMachine::Timer.new(2) do
                # orion: always indent blocks for readability
                # this and the three lines below should be indented
                # awesome block of code by the way
                other_players.each { |p| p.send "You scream."}
                @room.add_corpse MagicalItem.new "baby seal brain", "bloody"
                @room.add_corpse MagicalItem.new "corpse of #{name}", "sad little"
                end
                con.close_connection_after_writing
                @room.players.delete self
              end
            else
            send "You gaze at #{target.name} with narrow, cold eyes and thumb shells into your blue-steel shotgun."
            target.send "#{name} gazes at you with narrow, cold eyes and thumbs shells into #{pospronoun} blue-steel shotgun.".capitalize
            observers(target).each { |p| p.send "#{name} gazes at  #{target.name} with cold eyes, thumbing shells into #{pospronoun} blue-steel shotgun."}
            end
          else
            send "NOBODY HOME"
          end
        end
    end

    def do_flex(target)
      target = find_player_by_name(target)
      if target == nil
        send "You flex your baby seal blubber."
        other_players.each { |p| p.send "#{name} flexes."}
      else
        if target
          if target.name.downcase == name.downcase
            send "You flex and kiss your flipper."
            other_players.each { |p| p.send "#{name} flexes and kisses his flipper."}
          else
          send "You flex at #{target.name}."
          target.send "#{name} flexes at you.".capitalize          
          observers(target).each { |p| p.send "#{name} flexes at #{target.name}."}
          end
        else
          send "NOBODY HOME"
        end  
      end
    end    

    def do_kill(target)
      target = find_player_by_name(target)
      send "With a squeezetoy squeek of rage you flop adorably towards #{target.name} with bestial fury!\n"
      target.send "With a squeezetoy squeek, #{name} flops towards you adorably with intent to KILL!.\n"
      observers(target).each { |p| p.send "#{name} makes a tiny squeezetoy squeek and flops towards #{target.name}!"}
            
      n = 0

      # orion: holy crap this is awesome
      # did not toally read but the Diku way to do this was
      # to have a function like
      # 
      # def start_fighting(target)
      #    MUD::Fighting << self unless MUD::Fighting.include? self
      #    @fighting = target
      # end
      #
      # def stop_fighting
      #    MUD::Fighting.delete self
      #    @fighting = nil
      # end
      # 
      # in the server loop - way out in server.rb - inside the EventMachine::run
      #
      # EventMachine::PeriodicTimer.new(5) do
      #   MUD::Fighting.each do |attacker|
      #      attacker.perform_attack
      #   end   
      # end

       timer = EventMachine::PeriodicTimer.new(5) do

#offense swing!       
         if @inv.last == nil
           send "You nuzzle #{target.name} with murderous intent"
           target.send "#{name} gently nuzzles you with murderous intent"
           observers(target).each { |p| p.send "#{name} nuzzles #{target.name} with murderous intent"}           
         else
         send "You swing #{@inv.last} at #{target.name}"
         target.send "#{name} swings #{@inv.last} at you"
         observers(target).each { |p| p.send "#{name} swings #{@inv.last} at #{target.name}"}
         end         

         x = rand(10) + @inv.length + @cool + @dex
         y = rand(10) + target.wear.length + target.dex       
         if x > y
           target.hp = target.hp - (@inv.length + rand(@str))
           if (x-y) > 10
             send "You wack #{target.name} so hard that #{@inv.last} ripped from your mouth and gets stuck in their ribcage!"
             target.send "#{name} wacks you so hard that #{@inv.last} gets stuck in your ribcage!"
             target.embed.push(@inv.pop)
           else
             send "You wack #{target.name} with #{@inv.last}"
             target.send "#{name} wacks you with #{@inv.last}. Ouch!"
#            send "hit by #{(x-y)}"
#            target.send "hit by #{(x-y)}"
           end
         else
             send "You baby-flail inneffectually"
             target.send "#{name} flails at you ineffectually"
#          send  "miss by #{(x-y)}"
#          target.send "hit by #{(x-y)}"
         end

#defensive swing!
         if target.inv.last == nil
           send "#{target.name} nuzzles you in defense"
           target.send "You gently nuzzle #{name} defensively"
           observers(target).each { |p| p.send "#{target.name} nuzzles #{name} defensively"}
           
         else
         send "#{target.name} swings #{target.inv.last} at you"
         target.send "You swing #{target.inv.last} at #{name}"
         observers(target).each { |p| p.send "#{target.name} swings #{target.inv.last} at #{name}"}
         end
         
          x = rand(10) + @wear.length + @cool
          y = rand(10) + target.inv.length + target.dex + target.cool
  
         if x < y
           @hp = @hp - (target.inv.length + rand(target.str))
           send "hit by #{(y-x)}"
           target.send "hit by #{(y-x)}"
         else
           send  "miss by #{(y-x)}\n\n"
           target.send "hit by #{(y-x)}\n\n"
         end       
         timer.cancel if (n+=1) > 100
         
       end   
      
    end

    

=begin
The Diku fight system was
EventMachine::PeriodicTimer.new(5) { have_everyone_currently_in_a_fight_swing }
and commands like attack and flee would have you enter or exit the list of people who swing on that periodic timer
The difference being
Timer is for a single event in the future
PeriodicTimer is for heartbeat events and need be setup only once
=end
    
         
  end
end
