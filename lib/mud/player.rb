module MUD
  class Player
    include Commands
    attr_accessor :name, :hp, :vit, :con, :dirty, :bounce, :wear, :inv, :gender, :blubber, :bead, :pluck, :cute, :whisker, :embed, :wield, :attack_power, :defense_power, :fighting, :cranium, :ribcage, :eye, :flipper, :tail, :exp, :type, :berserk
    def initialize(name, con)
      @name = name
      @hp = 100
      @con = con
      @vit = 12
      @dirty = true
      @inventorybg = 10
      @inv = []
      @wear = []
      @embed = []
      @wield = []
      @cranium = []
      @ribcage = []
      @eye = []
      @flipper = []
      @tail = []
      @gender = :male
      @blubber = rand(10) + 1
      @bead = rand(10) + 1
      @pluck = rand(10) + 1
      @cute = rand(10) + 1
      @whisker = rand(10) + 1
      @attack_power = @wield.to_s.length.to_i + @bead
      @defense_power = @wear.to_s.length.to_i + @blubber
      @type = :seal
      @berserker = false
      @berserk_counter = 0
      @berserk = false
      @fighting = nil
      @exp = 0
      @position = :flop
      @readytoblow = false
      send "Welcome #{name}! You are a baby seal!"
      prompt
    end

    def to_room(room)
      if @room
        other_players.each { |p| p.send "#{name} has left." }
        @room.players.delete self
      end

      @room = room
      @room.players.push self
      other_players.each { |p| p.send "#{name} has arrived." }
    end

    def send(data)
      unless @dirty
        ## send a newline first if the person is waiting at their prompt
        @dirty = true
        @con.send_data "\n"
      end
      puts "[#{name}] #{data}"
      @con.send_data "#{data}\n"
    end

    def other_players
       @room.players.reject { |p| p == self}      
#      array.reject {|item| block } → an_array
#      Returns a new array containing the items in self for which the block is not true.      
    end
    
    def observers(target)
      a = @room.players.reject { |p| p == self}
      b = a.reject { |t| t == target }
    end
    
    def aliases
      {
        "l" => "look",
        "sc" => "score",
        "w" => "wear",
        "ww" => "wield",
        "un" => "unwield"    
      }
    end
    
    def command(cmd, arg)
      cmd = aliases[cmd] if aliases[cmd]
      begin
        @dirty = true
        case cmd
          when "berserker"; do_berserker
          when "possess"; do_possess
          when "ascend"; do_ascend
          when "swing"; do_swing(arg)
          when "rip"; do_rip(arg)
          when "unwield"; do_unwield
          when "kill"; do_kill(arg)
          when "wield"; do_wield
          when "flex"; do_flex(arg)
          when "sexchange"; do_sexchange
          when "digwest"; do_dig_west
          when "cold"; do_cold_eye(arg)
   #       when "go"; do_go(arg) soon, precious... soon...
          when "smile"; do_smile(arg)
          when "west"; do_west
          when "sc"; do_score
          when "score"; do_score
          when "exa"; do_exa(arg)
          when "say"; do_say(arg)
          when "look"; do_look(arg)
  #        when "l"; do_look
          when "exit"; do_exit
          when "help"; do_help         #basic
          when "drop"; do_drop
          when "d"; do_drop
          when "wear"; do_wear         #basic
  #        when "w"; do_wear
          when "remove"; do_remove     #basic
          when "r"; do_remove
          when "take"; do_take
          when "t"; do_take          
          when "chew"; do_chew         #basic
          when "c"; do_chew
          when ""; ## do_nothing
          when "bounce"; do_bounce
          when "b"; do_bounce
          when "flop"; do_flop         #basic
          when "f"; do_flop
          when "get"; do_get
          when "g"; do_get
          when "blow"; do_blow
          when "bb"; do_blow
          when "inventory"; do_inventory    #basic
          when "spit"; do_spit(arg)
          when "i"; do_inventory
          when "glue"; do_glue
          else ; send "Unknown Command: '#{cmd}'. Type 'help' for commands."
        end
      rescue MissingTarget => e
        # orion: this is a rescue block - if any function below this throws a missing target error it will jump up to here
        # this way you can avoid repeating yourself in all the targeted functions
        send "NOBODY HOME - can not find target '#{e.message}'"
      end
      @room.players.each { |p| p.prompt if p.dirty }
    end

    def find_player_by_name(name)
      return nil if name.nil?
      return self if name == "me"
      @room.players.detect { |p| p.name.downcase == name.downcase}
    end

    # orion: check this out - this version of the function has a ! after it and will throw an error if the person is not found
    # this format belog

    #   some_thing || some_other_thing

    # is used a lot - and make sense if you pronounce || as "or"
    # play with it in irb and see if you can make sense of it

    def find_player_by_name!(name)
      find_player_by_name(name) || raise(MissingTarget, name)
    end

    def do_berserker
      @berserker = true
      act(:squint) { |c| "#{c} #{c.verb} and #{c.look!} like it's poop-time!" }
      timer = EventMachine::PeriodicTimer.new(3) do     
      color = ["shag-carpeted", "leopard-print-upholstered ", "massive, horned", "cute little plush"]
      cc = color[rand(color.size)]
      toy = ["viking helmet", "viking battle helmet", "GWAR battle helmet", "viking dragonhelm", "Viking's football helmet"]
      tt = toy[rand(toy.size)]
      @wear.push MagicalItem.new tt, cc
      act { |c| "\n#{c} #{c.isare} infused with the spirit of the Vikings!\nA #{cc} #{tt} appears on #{c.pospronoun} head!\n"}      
      color = ["shag-carpeted", "leopard-print-upholstered", "massive, horned", "cute little plush squeezy-toy"]
      cc = color[rand(color.size)]
      toy = ["dragon horn of Valhalla", "viking battle axe", "Epiphone Goth 1958 Explorer Electric Guitar", "Gibson Explorer covered in duck stickers", "1982 Casio ROM Keyboard MT-18"]
      tt = toy[rand(toy.size)]      
      act { |c| "#{c} #{c.roar!} and #{c.hold!} a #{cc} #{tt} aloft!\n"}      
      @wield.push MagicalItem.new tt, cc
      timer.cancel 
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
      new_room = Room.new "Ice Tunnel", "It's cold.", 2
      send "You use your baby seal magic powers and dig westward!"
      send "You have created a new room!"
      other_players.each { |p| p.send "#{name} digs a new room to the west."}
    end

    def do_say(message)
      send "You say '#{message}'"
      other_players.each { |p| p.send "#{name} says '#{message}'" }
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
        other_players.each { |p| send "#{p.name} is here." }
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
          @hp = @hp - @wield.length
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
      if @room.item.empty?         
      else
        @room.item.count.times do
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
        @attack_power = @wield.to_s.length.to_i + @bead  
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
        color = ["red-painted", "green-painted", "blue-painted", "bloody", "rusty", "used", "rancid", "holy", "rubber", "ragged", "moldy", "tasteful", "ceremonial", "shag-carpeted", "dusty", "rotting", "solid-gold"]
        cc = color[rand(color.size)]
        toy = ["gimp suit", "stapler", "needle", "raincloud", "superman suit", "box jellyfish", "polar bear chew toy", "cardboard-cutout of Matthew McConaughey", "balloon", "harpoon", "battle-robot", "toy yeti", "home-liposuction kit", "polar-bear pelt", "jar of pickles", "batman cowl", "pixie wings", "hula-hoop", "glow sticks", "shrunken head", "vader helmet", "wonder-woman suit", "teacup", "dead baby seal", "Lady Liberty crown and torch", "collectable spoon", "witch's hat", "twelve-gauge shotgun", "piece of Einstein's brain", "talking stick", "tommygun", "underwood typewriter", "boquet of roses", "umbrella", "ring of power", "inflatable Silvia Plath doll", "egyptian mummy"]
        tt = toy[rand(toy.size)]
        @room.add_item MagicalItem.new tt, cc
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
        
    def act(verb = nil, target = nil, &blk)
      @room.players.each do |observer|
        c = Context.new :subject => self, :target => target, :verb => verb.to_s, :observer => observer
                 
        observer.send blk.call(c)
      end
    end
    
    def can_see?(target)
      true ## darkness/blindness/invisibility
    end

    def berserk?
      false
    end
  end
end


# orion:
# don't store more info than you need to - compute what you can... otherwise you end up with bugs 
# where you accidenty get "his" and "she" on the same player and the game seems retarded
# do this instead
#
# @gender = :male or @gender = :female
#
# then compute the pronouns instead of store them
#
# def pospronoun
#   case @gender
#   when :male   then "his"
#   when :female then "her"
#   else              "its"
#   end
# end
#

#    same same!
#    def act(verb, target = nil)
#          @room.players.each do |observer|
#            c = Context.new :subject => self, :target => target, :verb => verb.to_s, :observer => observer
#            observer.send yield(c)
#          end
#        end

#        def act(verb, target = nil, &block)
#          @room.players.each do |observer|
#            c = Context.new :subject => self, :target => target, :verb => verb.to_s, :observer => observer
#            observer.send block.call(c)
#          end
#        end
