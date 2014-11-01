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
      send "          rip: rip eye, rip tail, etc... if you get impaled, remember. they just gave you a weapon. rip foe location is an EVIL move."
      send "         Drop: you drop a magic item on the ground."
      send "         glue: glue two objects together. note- if you have three or more objects in your inventory, you'll lose them."
      send " Capitalized commands have shortcuts, the first letter of the command. l for look, w for wear, and so on. note: b = bounce, bb = blow bubble"
      send "\n Score or 'sc' gives you some vague information that will probably not be all that helpful. This game is completely rigged and you really don't stand any sort of chance."
      send "\n Death is not the end. You can possess, ascend"
      send "Autowield will turn you into a killing machine. kind of. it can get you killed too"
    end

    # orion: seems like you'd want to have these be @blubber instead of @str and @beadiness instead of @dex
    def do_score
      send "             Blubber: #{@blubber}"
      send "       Eye-Beadiness: #{@bead}"
      send "               Pluck: #{@pluck}"
      send "            Cuteness: #{@cute}"
      send "            Whiskers: #{@whisker}"
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
        act(:balance) { |c| "#{c.subject} carefully #{c.verb} #{@inv.last} on #{c.pospronoun} head." }
        @wear.push(@inv.pop)
        update_combat_stats
      end
    end

    def do_remove                 #set target self? pronoun
      if @wear.empty?
        send "You aren't wearing anything to remove."
      else
        
        act(:remove) { |c| "#{c.subject} #{c.verb} #{@wear.last} from  head."}
        @inv.push(@wear.pop)
        update_combat_stats
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
         @inv.each { |m| send "#{m}"}
      end

      if @wear.empty?
        send "You aren't wearing anything."
      else
        send "\n You are balancing the following on your head:"
        @wear.each { |m| send "#{m}"}
      end
        
      if @wield.empty?
          send "You aren't wielding anything."
      else
          send "\n You are wielding:"
          @wield.each { |m| send "#{m}"}
      end
#:cranium, :ribcage, :eye, :flipper, :tail      
      if @cranium.empty?     
      else
       @cranium.each { |m| send "#{m} has been embedded in your cranium."}
      end
      
      if @ribcage.empty?     
      else
        @ribcage.each { |m| send "#{m} has been embedded in your ribcage."}
      end
      
      if @eye.empty?     
      else
        @eye.each { |m| send "#{m} has been embedded in your eye."}
      end
      
      if @flipper.empty?     
      else
        @flipper.each { |m| send "#{m} has been embedded in your flipper."}
      end
      
      if @tail.empty?     
      else
        @tail.each { |m| send "#{m} has been embedded in your tail."}
       end
        
        send "You sense that your attack power is #{@attack_power}"
        send "You sense that your defense is #{@defense_power}"
    end

    def do_kill(name)
      n = 0
      if name
        target = find_player_by_name(name)
        if target
          target = find_player_by_name!(name)
          act(:flop, target) { |c| "With a squeezetoy squeek of rage #{c} #{c.verb} towards #{c.target} with intent to KILL!"}
          if @type == :ghost
            send "You're a ghost. You can't hurt anyone."            
          elsif target.type == :ghost
            send "#{target.name} is a ghost. You can't hurt them."
          elsif target.type == :seal
            timer = EventMachine::PeriodicTimer.new(5) do
            rip = rand(3)
              if rip == 0
                do_ripback(name)  
                target.do_ripback(@name)
              end  
            update_combat_stats
            target.update_combat_stats
            dead_check(target)
            timer.cancel if @hp < 0
            timer.cancel if target.hp < 0
            if @hp > 0 && target.hp > 0
              do_swing(target)              
            else
            end
            prompt
            target.prompt
            timer.cancel if (n+=1) > 100
          end
          end
        else
        end
      else
      end      
    end
    
    def update_combat_stats
      @defense_power = @wear.to_s.length.to_i + @blubber
      @attack_power = @wield.to_s.length.to_i + @bead
      
      run_autowield  
      if @berserker == true
        @berserk_counter += 1
        special_number = rand(3)
        if @berserk_counter == special_number
          
          act(:go) { |c| "#{c} #{c.froth!} and #{c.roar!} and #{c.verbes} BERSERK, rocking some wicked air guitar!"}
          @attack_power += 50
        else
        end
      else
      end        
    end
    
    def do_autowield
      if @autowield == false
      send "You turn on autowield. You will now wield things as quickly and as the opportunities arise. Should you lose your weapon, as soon as the opportunity presents itself, you will take it."
      @autowield = true
      else
      send "You turn off autowield."
      @autowield = false
      end      
    end


    
    def run_autowield
      if @autowield == false
      else
        if @wield.empty?
          if @inv.empty?
            if @room.item.empty?
              if @wear.empty?
                act { |c| "#{c} #{c.squeek!} feeling helpless!"}
              else
                act { |c| "#{c} #{c.flip!} a #{@wear.last} from #{c.pospronoun} head into #{c.pospronoun} mouth!"}
                @wield.push(@wear.pop)
              end
            else
              act { |c| "#{c} hastily #{c.pick!} up a #{@room.item.last} and #{c.wield!} it in #{c.pospronoun} mouth."}
              @wield.push(@room.item.pop)  
            end  
          else
            act { |c| "#{c} hastily #{c.grip!} a #{@inv.last} in #{c.pospronoun} mouth."}
            @wield.push(@inv.pop)
          end          
        else
        end        
      end
    end   
    
    def dead_check(target)
      if target.hp > 0
      else
        redballoon = rand(100)
        if redballoon < 98   
          act(:float, target) { |c| "\nA magic red balloon appears to rescue #{c.target}!\n#{c.target} #{c.tarverb} into the sky on a magic red balloon!\n\nThe magic red balloon pops and #{c.target} #{c.come!} crashing down to #{target.pospronoun} death!\n#{c.target} #{c.tisare} DEAD!!!\n"}
        else
          act { |c| "#{c.target} #{c.tisare} DEAD!!!\n"}
        end
        

          @hp = @hp + target.whisker
          @cute = @cute + target.cute 
          @blubber = @blubber + target.blubber
          @whisker = @whisker + target.whisker
          @pluck = @pluck + target.pluck
          @bead = @bead + target.bead
          @exp = @exp + 1 + target.exp
          
          impalements = target.eye + target.ribcage + target.tail + target.flipper + target.cranium
            if impalements.empty?

            else
            impale_string = "impaled with #{impalements}"
            end
          @room.add_corpse MagicalItem.new "corpse of #{target.name} #{impale_string}", "sad little"     
          send "You feel Stronger! You feel cuter! You gain #{(1 + target.exp)} experience!"
#          target.name = "The ghost of #{target.name}"
          target.type = :ghost
          
          if @type == :zombie
            do_zombie_coup_de_grace(target)
          else
          end
          
          
      end
      if @hp > 0    
      else   
        redballoon = rand(100)
        if redballoon < 90         
          act(:float, target) { |c| "\nA magic red balloon appears to rescue #{c}!#{c} #{c.verb} into the sky on a magic red balloon!\n\nThe magic red balloon pops and #{c} #{c.come!} crashing down to #{c.pospronoun} death!\n#{c} #{c.isare} DEAD!!!\n" }
        else
         act { |c| "#{c} #{c.isare} DEAD!!!\n"}
        end
        
         target.hp = target.hp + @whisker
         target.cute = target.cute + @cute 
         target.blubber = target.blubber + @blubber
         target.whisker = target.whisker + @whisker
         target.pluck = target.pluck + @pluck
         target.bead = target.bead + @bead
         target.exp = target.exp + 1 + @exp
         impalements = @eye + @ribcage + @tail + @flipper + @cranium
           if impalements.empty?

           else
           impale_string = "impaled with #{impalements}"
           end
         @room.add_corpse MagicalItem.new "corpse of #{name} #{impale_string}", "sad little"
         target.send "You feel Stronger! You feel cuter! You gain #{(1 + @exp)} experience!"
#         @name = "The ghost of #{@name}"
         @type = :ghost
         
         
         if target.type == :zombie
           do_zombie_coup_de_grace(target)
         else
         end
      end      
    end    
    
    def do_zombie_coup_de_grace(target)
      send "coup de grace"
    end
    
    def do_ascend
      if @type == :ghost
        act(:ascend) { |c| "#{c} #{c.verb} to baby seal heaven on a magic blue balloon." }   
        @room.players.delete self
        con.close_connection_after_writing
      else
        send "You aren't dead!"
      end
    end
    
    def do_possess
      if @type == :ghost
        if @room.item.empty?
          "There are no objects in the room to possess."
        else
          if @whisker == 0
            send "You are all out magic whiskers"
          else
            act(:pluck) { |c| "#{c} #{c.verb} a magical whisker from #{c.pospronoun} muzzle and takes possession of #{@room.item.last}"} 
            @name = "#{@room.item.last} possessed by #{@name}"
            @type = :zombie
            @hp = 100
            @whisker = @whisker - 1
            @room.item.pop
          end
        end        
      else
        "You aren't dead!"
      end
    end
        
    def do_swing(target)
      @fighting = target
      if @position == :flop
        if @wield.empty?
          aggressive_nuzzle(target)
        else
          decide_hit(target)
        end
        if target.wield.empty?
          defensive_nuzzle(target)     
        else
          defensive_maneuver(target)
        end  
      else #bouncing attack
        if @wield.empty?
          aggressive_nuzzle(target)       
        else
          act(:bounce, target) { |c| "#{c} #{c.bounce!} into the air and #{c.bat!} at #{c.target} with #{@wield}!\n"}
          @position = :flop
          decide_hit(target)
        end
      end
    end
    
    def aggressive_nuzzle(target)
      nuzzlenumber = rand(6)
      case nuzzlenumber
        when 0; act(:nuzzle, target) { |c| "#{c} #{c.verb} #{c.target} aggressively."}
        when 1; act(:nuzzle, target) { |c| "#{c} #{c.verb} #{c.target} with murderous intent."}
        when 2; act(:pin, target) { |c| "#{c} #{c.verb} #{c.target} to the ground and #{c.tickle!} #{c.target} with #{c.pospronoun} nose."}   
        when 3; act(:bark, target) { |c| "#{c} #{c.verb} at #{c.target}!"}
        when 4; act(:charge, target) { |c| "#{c} babyflipperflop-#{c.verb} and #{c.bump!} #{c.target} with #{c.pospronoun} chest."}
        when 5; act(:poop, target) { |c| "#{c} #{c.verb} #{c.pospronoun} diaper."}
        else
      end
    end    
        
    def defensive_nuzzle(target)
      nuzzlenumber = rand(6)
      case nuzzlenumber
        when 0; act(:nuzzle, target) { |c| "#{c.target} #{c.tarverb} #{c} defensively." }
        when 1; act(:whine, target) { |c| "#{c.target} #{c.tarverb} and makes cute little motorboat sounds with #{c.tarpospronoun} mouth.".capitalize }
        when 2; act(:squeek, target) { |c| "#{c.target} #{c.tarverb} in protest and curls up into a little ball." } 
        when 3; act(:fart, target) { |c| "#{c.target} #{c.tarverb} after #{c} #{c.poke!} at #{c.tarpospronoun} blubber." }
        when 4; act(:make, target) { |c| "#{c.target} #{c.tarverb} a little crying sound towards the cold, indifferent sky.".capitalize }
        when 5; target.send "You try to babyflipperflop away in the snow."
                other_players.each { |p| p.send "#{target.name} tries to babyflipperflop away in the snow." }
        else
      end      
    end

    def decide_hit(target)      
      x = rand(10)
      y = rand(10)
      dumb_luck = rand(100)
      coin_of_fate = rand(10)
      case coin_of_fate
      when 0; x = x + dumb_luck
      when 1; y = y + dumb_luck  
      else
      end              
        if (@attack_power + x) < (target.defense_power + y)
          if target.wield.empty?
            hitnumber = @attack_power + x
            outcome(hitnumber, target)
          else  
            send "MISS  attack power: #{@attack_power} x: #{x} defense power: #{target.defense_power} y: #{y}  attack miss by: #{(target.defense_power + y) - (@attack_power + x)}"
            hitnumber = -((target.defense_power + y) - (@attack_power + x))         
            outcome(hitnumber, target)  
          end      
        else
          if @wield.empty?
            hitnumber = -(target.defense_power + y)
            outcome(hitnumber, target)
          else  
            send "HIT  attack power: #{@attack_power} x: #{x} defense power: #{target.defense_power} y: #{y} attack hit by: #{-(target.defense_power + y) + (@attack_power + x)}"
            hitnumber = (@attack_power + x) - (target.defense_power + y) 
            outcome(hitnumber, target)
          end
        end          
    end

    def defensive_maneuver(target)
      if target.wield.empty?
        defensive_nuzzle(target)
      else
        x = rand(3000)
        send x
        target.send x
      end
      
    end

    def outcome(hitnumber, target)
      
        wound(target, hitnumber)     
        case hitnumber
          
          when -1000..-51
               impale(target, hitnumber)   
          when -50..-31
             act(:bellyflop, target) { |c| "#{c} #{c.bounce!} into the air and #{c.verbes} into #{c.tarpospronoun} #{target.wield}." }
               knock(target, hitnumber)
          when -30..-21
             act(:throw, target) { |c| "#{c} #{c.verb} #{c.pospronoun} face on #{c.tarpospronoun} #{target.wield}." }
          when -20..-11
             act(target) { |c| "#{c} #{c.flop!} and #{c.bonk!} #{c.pospronoun} head on the snow." }
          when -10..-1
             act(:wack, target) { |c| "#{c.target} #{c.tarverb} #{c} with a fish. #{c} #{c.look!} SAD.\n" }
          when 0..10
             act(:puke, target) { |c| "#{c} #{c.verb} on #{c.pospronoun} bib and #{c.burst!} into tears." }
          when 11..20
             act(:roar, target) { |c| "#{c} #{c.verb} and #{c.bat!} at #{c.target} with a #{@wield}." }
          when 21..30
             act(:oink, target) { |c| "#{c} #{c.verb} like a pig and #{c.nuzzle!} #{c.target} with a #{@wield}." }
          when 31..50
             act(:crash, target) { |c| "#{c} #{c.bounce!} into the air and #{c.verbes} into #{c.target}" }
               knock(target, hitnumber)        
          when 51..1000
               impale(target, hitnumber)     
          else
          end           
    end
    
    def wound(target, hitnumber)
      if hitnumber > 0
      target.hp -= hitnumber
      else
      @hp += hitnumber
      end    
    end
    
    def impale(target, hitnumber)
      if hitnumber < 0
        loc = rand(5)
        case loc
          when 0; loc = @cranium
                  loc_str = "cranium"
          when 1; loc = @ribcage 
                  loc_str = "ribcage"
          when 2; loc = @eye 
                  loc_str = "eye"
          when 3; loc = @flipper 
                  loc_str = "flipper"
          when 4; loc = @tail 
                  loc_str = "tail"        
        else
        end
        act(target) { |c| "#{c} #{c.trip!} and #{c.impale!} #{c.pospronoun}self on #{c.tarpospronoun} #{target.wield}." }
        loc.push(target.wield.pop)
      else
        loc = rand(5)
        case loc
          when 0; loc = target.cranium 
                  loc_str = "cranium"
          when 1; loc = target.ribcage 
                  loc_str = "ribcage"
          when 2; loc = target.eye 
                  loc_str = "eye"
          when 3; loc = target.flipper 
                  loc_str = "flipper"
          when 4; loc = target.tail 
                  loc_str = "tail"
        else
        end
        act(:impale, target) { |c| "#{c} #{c.verb} #{c.target} in the #{loc_str} with #{@wield}." }
        loc.push(@wield.pop)
      end            
    end
    
    def knock(target, hitnumber)
      if hitnumber < 0
        if @wear.empty?
          act(:wack, target) { |c| "#{c.target} #{c.tarverb} #{c} hard on the nose!"}
        else
          arrayloc = rand(@wear.size)
          arrayitem = @wear[arrayloc]
          act(target) { |c| "#{c} #{c.trip!} and #{c.bang!} #{c.pospronoun} head on #{c.tarpospronoun} #{target.wield}, knocking a #{arrayitem} from #{c.pospronoun} head." }
          @room.item.push(@wear.slice!(arrayloc))          
        end           
      else #hitnumber > 0
        if target.wear.empty?
          act(:wack, target) { |c| "#{c} #{c.verb} #{c.target} hard on the nose!"}
        else
          arrayloc = rand(target.wear.size)
          arrayitem = target.wear[arrayloc]
          act(:wack, target) { |c| "#{c} #{c.verb} #{c.target} so hard that it knocks a #{arrayitem} from his head!"}
          @room.item.push(target.wear.slice!(arrayloc))          
        end               
      end      
    end
    
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

    def do_berserker
      @berserker = true
      act(:squint) { |c| "#{c} #{c.verb} and #{c.look!} like it's poop-time!" }
      timer = EventMachine::PeriodicTimer.new(3) do     
        helm, toy = MagicalItem.bazerker_items
        @wear.push helm
        act { |c| "\n#{c} #{c.isare} infused with the spirit of the Vikings!\nA #{helm.color} #{helm.name} appears on #{c.pospronoun} head!\n"}      
        act { |c| "#{c} #{c.roar!} and #{c.hold!} a #{toy.color} #{toy.name} aloft!\n"}      
        @wield.push toy
        @hp += rand(500)
        update_combat_stats
        timer.cancel 
      end      
    end
    
    def do_pirate
      act { |c| "#{c} #{c.begin!} murmuring an old pirate song."}
      timer = EventMachine::PeriodicTimer.new(2) do 
      color = ["mangy", "salt water taffy", "barnacled", "rusty"]
      cc = color[rand(color.size)]
      cc2 = color[rand(color.size)]
      toy = ["eye patch", "parrot", "peg leg", "bottle of grog", "pirate hat"]
      tt = toy[rand(toy.size)]
      tt2 = toy[rand(toy.size)]
      act { |c| "The spirits of the pirate kings smile down upon #{c}."}
      act { |c| "#{c} #{c.hold!} a #{cc} #{tt} aloft!\n"} 
      act { |c| "A #{cc2} #{tt2} appears on #{c.pospronoun} head!\n"}
      @wield.push MagicalItem.new tt, cc
      @wear.push MagicalItem.new tt2, cc2
      @hp += rand(500)
      update_combat_stats
      timer.cancel
      end
    end
    
    def do_zombie
      if @type == :ghost
        @hp = rand(1000)
        @type = :zombie
        act(:snarl) { |c| "#{c} #{c.verb} and #{c.groan!} and #{c.rise!} from the dead to hunt for BRAINS!"}
      else
        send "You must be dead before you can become a zombie."
      end
    end

    def do_spit(name)
      # orion: note I can aboid the NOBDY home thing here since it will jump up to the exception handler above
      # also - target.name is a pain to type ... if you have Player#to_s return @name we could just say 'target' here...
      if name
        target = find_player_by_name!(name)
        act(:spit, target) { |c| "#{c} #{c.spit!} on #{c.target}." }
      else
        act { |c| "#{c} #{c.spit!}." }
      end
    end

    def do_dig_west
      west = @room.coord_x - 1
      new_room = Room.new "Ice Tunnel", "It's cold.", @room.number + 1, west, @room.coord_y, @room.coord_z
      send "You use your baby seal magic powers and dig westward!"
      send "You have created a new room!"
      other_players.each { |p| p.send "#{name} digs a new room to the west."}
      
    end
    
#    def do_west
#      to_room(1)
#    end
    
    def do_say(message)
      send "You say '#{message}'"
      other_players.each { |p| p.send "#{name} says '#{message}'" }
    end

    def do_ripback(name)
      if name
        target = find_player_by_name(name)
          if target
            target = find_player_by_name!(name)            
            if !target.ribcage.empty?
              do_unwield
              act(target) { |c| "#{c} #{c.rip!} a #{target.ribcage.last} from #{c.tarpospronoun} ribcage!"}
              @wield.push(target.ribcage.pop)
              target.hp = target.hp - @wield.length
              update_combat_stats
            end
            if !target.tail.empty?
              do_unwield
              act(target) { |c| "#{c} #{c.rip!} a #{target.tail.last} from #{c.tarpospronoun} tail!"}
              @wield.push(target.tail.pop)
              target.hp = target.hp - @wield.length
              update_combat_stats
            end
            if !target.flipper.empty?
              do_unwield
              act(target) { |c| "#{c} #{c.rip!} a #{target.flipper.last} from #{c.tarpospronoun} flipper!"}
              @wield.push(target.flipper.pop)
              target.hp = target.hp - @wield.length
              update_combat_stats
            end
            if !target.cranium.empty?
              do_unwield
              act(target) { |c| "#{c} #{c.rip!} a #{target.cranium.last} from #{c.tarpospronoun} cranium!"}
              @wield.push(target.cranium.pop)
              target.hp = target.hp - @wield.length
              update_combat_stats
            end
            if !target.eye.empty?
              do_unwield
              act(target) { |c| "#{c} #{c.rip!} a #{target.eye.last} from #{c.tarpospronoun} eye!"}
              @wield.push(target.eye.pop)
              target.hp = target.hp - @wield.length
              update_combat_stats
            end
          else
          end
        else
        end

=begin
from MG:
1. If you're calling do_unwield in every case, then why not just call it once, prior to the stack of if statements? Same with update_combat_stats, you should just call that once as well, but you obviously want to make sure that it needs to be called. I'll handle this w/ a boolean variable, which you declare after "if target", something like this:

if target
 target = find_player_by_name!(name)
 call_update = false
 if !target.ribcage.empty?
 ....

And then, after all those if statements: update_combat_stats if call_update -- this will be much more efficient that calling the method a possible five times.

2. target = find_player_by_name!(name) -- I saw that Orion setup this method, but it's misleading, b/c the ! symbol generally means that the method will somehow change the object it's called on. You've probably already read this. If not, look at String#upcase vs String@upcase! -- upcase() will return a separate String object while upcase!() will modify the String object itself and returns nil. Orion is obviously aware of this, but I wanted to make sure you were conscious of the assumption drawn from that notation.

3. This is another place where you can shorten your increment assignments: target.hp = target.hp - @wield.length could be : target.hp -= @wield.length


Nothing major, just some food-for-thought type stuff. Hope it helps.

Just saw why Orion used find_player_by_name!() -- in the Rails library, it signifies a method that throws an exception upon failure, which this method does, rather than failing silently.

=end      
#      arrayloc = rand(target.wear.size)
#      arrayitem = target.wear[arrayloc]
#      act(:wack, target) { |c| "#{c} #{c.verb} #{c.target} so hard that it knocks a #{arrayitem} from his head!"}
#      @room.item.push(target.wear.slice!(arrayloc))
      
    end
    
    def do_look(name)
      if name
        target = find_player_by_name(name)
          if target
            target = find_player_by_name!(name)
            act(:sniff, target) { |c| "#{c} #{c.sniff!} #{c.target}." }
            send "#{target.subpronoun} has carefully stacked and balanced #{target.wear.size} things on #{target.pospronoun} cute little noggin."
            target.wear.each do |item|
            send "#{item}"
            end
            send "\n#{target.subpronoun} carries #{target.inv.size} things on #{target.pospronoun} back."
            target.inv.each do |item|
            send "#{item}"            
            end
            if target.wield.empty?
              send "\n#{target.subpronoun} is as defenseless and helpless as a baby seal!"
            else
              target.wield.each do |item|
              send "\n#{target.subpronoun} wields #{item} in #{target.pospronoun} mouth.\n"
              end
            end
               
            if target.cranium.empty?     
            else
            target.cranium.each { |m| send "#{m.item} has been embedded in #{target.pospronoun} cranium."}
            end
            if target.ribcage.empty?     
            else
            target.ribcage.each { |m| send "#{m.item} has been embedded in #{target.pospronoun} ribcage."}
            end
            if target.eye.empty?     
            else
            target.eye.each { |m| send "#{m.item} has been embedded in #{target.pospronoun} eye."}
            end
            if target.flipper.empty?     
            else
            target.flipper.each { |m| send "#{m.item} has been embedded in #{target.pospronoun} flipper."}
            end
            if target.tail.empty?     
            else
            target.tail.each { |m| send "#{m.item} has been embedded in #{target.pospronoun} tail."}
            end    
          else
          end
      else
        send "#{@room.title}"
        send "#{@room.desc}"
        send "#{@room.bubblegum} pieces of bubblegum sit here."
        send " [------]"
          
        other_players.each { |p| send "A baby #{p.type} named #{p.name} is here." }
          
        if @room.item.empty?
           send "no items"
        else
          if @room.item[1] == nil
            send "You see a #{@room.item}"
          else
            copyitems = @room.item.clone
            lastitem = copyitems.pop
            mainstring = copyitems.join(", a ")
            send "You see a #{mainstring}, and a #{lastitem}."
          end                   
        end      
      end
    end
    
    def do_rip(loc)
        case loc
        when "cranium"
          @loc = @cranium
          locs = "cranium"
        when "ribcage"
          @loc = @ribcage
          locs = "ribcage"
        when "eye"
          @loc = @eye
          locs = "eye"
        when "tail"
          @loc = @tail
          locs = "tail"
        when "flipper"
          @loc = @flipper
          locs = "flipper"     
      else
        send "your call is important to us. please stay on the line."
      end  
        if @loc.empty?
          send "nothing is impaling you in the #{locs}"
        else
          if @wield.empty?
          else  
          act(:drop) { |c| "#{c} #{c.verb} #{@wield} to the ground."}
          @room.item.push(@wield.pop)
          end        
          act(:rip) { |c| "#{c} #{c.grit!} #{c.pospronoun} teeth and #{c.verb} #{@loc.last} from #{c.pospronoun} #{locs}. BLOOD spurts from a gaping hole in #{c.pospronoun} #{locs} and #{c} #{c.ROAR!}!" }
          @wield.push(@loc.pop)
          @hp -= @wield.length
          update_combat_stats
        end      
      
    end
    
    def do_exit
      send "A Polar Bear Eats You!"
      other_players.each { |p| p.send "#{name} was dragged away by a polar bear!" }
      con.close_connection_after_writing
      @room.players.delete self    
    end

    def do_drop
      if @inv.empty?
        send "you're not carrying anything to drop."
      else    
        act(:drop) { |c| "#{c} #{c.verb} #{@inv.last} on the ground." }
        @room.item.push(@inv.pop)
      end    
    end

    def do_take
      do_get
      if @room.item.empty? || @inv.count >= 3
      else
        @room.item[0..2].count.times do
          act(:pick) { |c| "#{c} #{c.verb} up #{@room.item.last} and #{c.flip!} it on #{c.pospronoun} back." }
          @inv << @room.item.pop
        end
      end 
    end

    def do_bounce
      bouncygum = rand(4) + 1   
      @room.bubblegum += bouncygum
      @position = :bounce
      act(:bounce) { |c| "#{c} #{c.verb} up and down and #{bouncygum} pieces of magic bubblegum appear!" }
    end

    def do_get
      if @room.bubblegum == 0        
      else
        act(:pick) { |c| "#{c} #{c.verb} up #{@room.bubblegum} pieces of magical bubblegum." }
        @inventorybg += @room.bubblegum
        @room.bubblegum = 0
      end
    end
    
    def do_wield
      if @inv.empty?
        "You aren't carrying anything to wield."
      else
        if wield.empty?
        @wield.push(@inv.pop)
        act(:wield) { |c| "#{c} #{c.verb} #{@wield} in #{c.pospronoun} mouth."}
        @attack_power = @wield.to_s.length.to_i + @bead  
        else
        act { |c| "#{c} #{c.drop!} #{@wield} from #{c.pospronoun} mouth and #{c.grip!} #{@inv.last} menacingly." }
        @room.item.push(@wield.pop)
        @wield.push(@inv.pop)
        update_combat_stats
        end
      end
    end
    
    def do_unwield
      if @wield.empty?
        "You aren't wielding anything."
      else
        act(:flip) { |c| "#{c} #{c.verb} #{@wield} from #{c.pospronoun} mouth onto #{c.pospronoun} back."}
        @inv.push(@wield.pop)
        @attack_power = @wield.to_s.length.to_i + @bead        
      end
    end

    def do_blow
      unless @readytoblow
        send "You must chew the bubblegum before you can blow a bubble!"
      else
        act(:blow) { |c| "#{c} #{c.verb} a bright red, maggic bubble until it POPS!"}
        @readytoblow = false
        @room.add_item MagicalItem.random_toy
      end
    end
     
    def do_glue
      unless @readytoblow
        send "You must chew the gum before you can use it as glue!"
      else
        if @inv.empty?
          send "You need at least two things in your inventory to glue together."
        else
          act(:glue) { |c| "#{c} carefully #{c.verb} #{@inv[0]} to #{@inv[1]} with a gooey wad of magic bubblegum."}       
          @inv << MagicalItem.new("glued to #{@inv.shift}","#{@inv.shift}")
        end  
      end
    end     
        
    def prompt
      con.send_data "hp: #{hp} cute: #{cute}> "
      @dirty = false
    end

    def subpronoun
      case @gender
        when :male  then    "He"
        when :female then   "She"
        else                "It"
      end
    end

    def pospronoun
      case @gender
        when :male   then "his"
        when :female then "her"
        else              "its"
      end
    end
    
    def objpronoun
      case @gender
        when :male     then "him"
        when :female   then "her" 
        else                "its"
      end
    end    

    def do_sexchange
      if gender == :male
        @gender = :female
        act { |c| "#{c} #{c.grow!} girl parts." }
      else
        @gender = :male
        act { |c| "#{c} #{c.zoom!} boy parts and #{c.smile!}." }
      end
    end        

=begin      
      
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
    
    def attack_roll
      rand(10) + @inv.length + @cool + @dex
    end
    
    def defense_roll
      rand(10) + @wear.length + @dex
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
