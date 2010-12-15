module MUD
  module Commands
    def do_help
      send "                BABY SEAL MUD COMMANDS"
      send "          say: just type say and your message"
      send "         Look: examine your immediate surroundings."
      send "         exit: leave the game"
      send "         help: what you're looking at right now."
      send "       Bounce: makes magic bubblegum. also how you move."
      send "         Flop: for resting and chewing bubblegum."
      send "          Get: pick up magic bubblegum."
      send "         Chew: prepare for magic! precurser to blow."
      send "         Blow: make powerful tools to aid you!"
      send "         Take: picks up the most recent item you made."
      send "    Inventory: examine your inventory."
      send "         Wear: wield that magic!"
      send "       Remove: un-wield that magic!"
      send "         Drop: you drop a magic item on the ground."
      send "         glue: glue two objects together. note- if you have three or more objects in your inventory, you'll lose them."
      send " Capitalized commands have shortcuts, the first letter of the command. l for look, w for wear, and so on. note: b = bounce, bb = blow bubble"
      send "\n Score or 'sc' gives you some vague information that will probably not be all that helpful. This game is completely rigged and you really don't stand any sort of chance."             
    end
    
    def do_score
      send "             Blubber: #{@str}"
      send "       Eye-Beadiness: #{@dex}"
      send "               Pluck: #{@cool}"
      send "            Cuteness: #{@luck}"
      send "      Whisker Length: #{@wis}"
      send "                                XP: #{@exp}"     
    end  

    def do_flop
      send "You grunt adorably as you flop down on the ground to rest."
      other_players.each { |p| p.send "#{name} flops down onto the ground with an adorable little grunt."}
      @position = true
    end
   
    def do_wear
      if @inv.empty?
        send "Your inventory is empty."
      else
        send "You carefully balance #{@inv.last} on your head."
        other_players.each { |p| p.send "#{name} carefully balances a #{@inv.last} on his head. "}
        @wear.push(@inv.pop)
      end
    end

    def do_remove
      if @wear.empty?
        send "You aren't wearing anything to remove."
      else
        send "You remove a #{@wear.last} from your head. "
        other_players.each { |p| p.send "#{name} removes a  #{@wear.last} from his head. "}
        @inv.push(@wear.pop)
      end
    end

    def do_chew
      unless @position
        send "One cannot chew gum and bounce at the same time."
      return
      end      
      if @inventorybg > 0
        send "You begin chewing one of your magic pieces of bubblegum."
        other_players.each { |p| p.send "#{name} begins chewing a piece of magic bubblegum."}
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
    
    def do_smile(target)
      target = find_player_by_name(target)
      if target == nil
        send "You smile."
        other_players.each { |p| p.send "#{name} smiles."}
      else
        if target
          if target.name.downcase == name.downcase
            send "You smile at yourself. Because that's what creepy seals do."
            other_players.each { |p| p.send "#{name} smiles at himself. He are thinking about something."}
          else
          send "You smile at #{target.name}."
          target.send "#{name} smiles at you showing rows and rows of razor-sharp teeth.".capitalize          
          observers(target).each { |p| p.send "#{name} smiles at #{target.name} revealing years of tawdry British dental work."}
          end
        else
          send "NOBODY HOME"
        end  
      end
    end    

    def do_cold_eye(target)
        target = find_player_by_name(target)
        if target == nil
          send "You gaze at the horizon and calmly thumb shells into your blue-steel shotgun."
          other_players.each { |p| p.send "#{name} gazes at the horizon and calmly thumb shells into his blue-steel shotgun."}
        else
          if target
            if target.name.downcase == name.downcase
              send "You thumb shells into your blue-steel shotgun and put it in your mouth."
              other_players.each { |p| p.send "#{name} thumbs shells into his blue-steel shotgun and puts it in his mouth."}
              EventMachine::Timer.new(2) do
                send "You pull the trigger and BLAM! Baby Seal brains EVERYWHERE! Nooooo!"
                other_players.each { |p| p.send "#{name} pulls the trigger and BLAM!\nBaby Seal brains everywhere!" }
                EventMachine::Timer.new(2) do
                other_players.each { |p| p.send "You scream."}
                @room.add_item MagicalItem.new "baby seal brain", "bloody"
                @room.add_item MagicalItem.new "corpse of #{name}", "sad little"              
                end
                con.close_connection_after_writing
                @room.players.delete self 
              end           
            else
            send "You gaze at #{target.name} with narrow, cold eyes and thumb shells into your blue-steel shotgun."
            target.send "#{name} gazes at you with narrow, cold eyes and thumbs shells into his blue-steel shotgun.".capitalize          
            observers(target).each { |p| p.send "#{name} gazes at  #{target.name} with cold eyes, thumbing shells into his blue-steel shotgun."}
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
            send "You flex kiss your flipper."
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
    
         
  end
end
