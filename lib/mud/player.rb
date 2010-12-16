module MUD
  class Player
    include Commands
    attr_accessor :name, :hp, :vit, :con, :dirty, :bounce, :wear, :inv, :gend, :pospronoun, :objpronoun, :subpronoun, :str, :dex, :cool, :luck, :wis, :embed

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
      @gend = "neuter"
      @pospronoun = "its"
      @objpronoun = "it"
      @subpronoun = "it"
      @str = rand(10) + 1
      @dex = rand(10) + 1
      @cool = rand(10) + 1
      @luck = rand(10) + 1
      @wis = rand(10) + 1
      @exp = 0
      @position = true
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
    
    def command(cmd, arg)
      begin
        @dirty = true
        case cmd
          when "kill"; do_kill(arg)
          when "flex"; do_flex(arg)
          when "sexchange"; do_sexchange(arg)
          when "digwest"; do_dig_west
          when "cold"; do_cold_eye(arg)
   #       when "go"; do_go(arg) soon, precious... soon...
          when "smile"; do_smile(arg)
          when "west"; do_west
          when "sc"; do_score
          when "score"; do_score
          when "exa"; do_exa(arg)
          when "say"; do_say(arg)
          when "look"; do_look
          when "l"; do_look
          when "exit"; do_exit
          when "help"; do_help         #basic
          when "drop"; do_drop
          when "d"; do_drop
          when "wear"; do_wear         #basic
          when "w"; do_wear
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

    def do_spit(name)
      # orion: note I can aboid the NOBDY home thing here since it will jump up to the exception handler above
      # also - target.name is a pain to type ... if you have Player#to_s return @name we could just say 'target' here...
      if name
        target = find_player_by_name!(name)
        act_spit(target) { |c| "#{c.subject} #{c.verb} on #{c.target}." }
      else
        act_spit { |c| "#{c.subject} #{c.verb}." }
      end
    end

    def do_dig_west
      new_room = Room.new "Ice Tunnel", "It's cold.", 2
      send "You use your baby seal magic powers and dig westward!"
      send "You have created a new room!"
      other_players.each { |p| p.send "#{name} digs a new room to the west."}
    end
=begin
    def do_exa(name)
      target = find_player_by_name(name)
      if target
        send "You examine #{target.name}."
        send "They have #{target.wear.size} things."
        target.wear.each do |item| 
        send "#{item}"        
      else
        send "NOBODY HOME"
      end  
    end
=end
    def do_say(message)
      send "You say '#{message}'"
      other_players.each { |p| p.send "#{name} says '#{message}'" }
    end

    def do_look
      send "#{@room.title}"
      send "#{@room.desc}"
      send "#{@room.bubblegum} pieces of bubblegum sit here."
      send " [------]"
      other_players.each { |p| send "#{p.name} is here." }
      if @room.item.empty?
        send "no items"
      else
        @room.item.each { |m| send "#{m.item} sits here."}
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
        send "You drop #{@inv.last} on the ground."  
        other_players.each { |p| p.send "#{name} drops #{@inv.last} on the ground."}
      @room.item.push(@inv.pop)
      end    
    end

    def do_take
      if @room.item.empty?
         send "empty room"
      else
        send "You flip #{@room.item.last} onto your back."
        other_players.each { |p| p.send "#{name} flips #{@room.item.last} on his back."}
        @inv << @room.item.pop             
      end 
    end

    def do_bounce
      send "You start bouncing up and down!"
      other_players.each { |p| p.send "#{name} starts bouncing up and down!"}
      bouncygum = rand(4) + 1   
      @room.bubblegum += bouncygum
      @position = false
      send "You make #{bouncygum} magic pieces of bubblegum!"
      other_players.each { |p| p.send "#{name} makes #{bouncygum} magic pieces of bubblegum!" }  
    end

    def do_get
      if @room.bubblegum == 0
        send "There is no bubblegum here!"
      else
        send "You pick up #{@room.bubblegum} pieces of magical bubblegum."
        other_players.each { |p| p.send "#{name} picks up #{@room.bubblegum} pieces of magical bubblegum."}
        @inventorybg += @room.bubblegum
        @room.bubblegum = 0
      end
    end

    def do_blow
      unless @readytoblow
        send "You must chew the bubblegum before you can blow a bubble!"
      else
        send "You blow a bright red, magic bubble until it POPS!"
        other_players.each { |p| p.send "#{name} blows a bright red magic bubble until it POPS!"}
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
          send "You carefully glue #{@inv[0]} to #{@inv[1]} with your magical bubblegum."
          other_players.each { |p| p.send "#{name} carefully glues #{@inv[0]} to  #{@inv[1]} with his magical bubblegum."}         
          @inv << MagicalItem.new("glued to #{@inv.shift}","#{@inv.shift}")
        end  
      end
    end     
        
    def prompt
      con.send_data "h:#{hp} v:#{vit}> "
      @dirty = false
    end
    
    def do_sexchange(gend)
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
    
      if gend == "male"
        @pospronoun = "his"
        @objpronoun = "him"
        @subpronoun = "he"
        send "You pray to the baby seal gods and are granted a penis!"
        other_players.each { |p| p.send "#{name} prays to the baby seal gods real hard and is granted a penis!"}
      elsif gend == "female"
        @pospronoun = "her"
        @objpronoun = "her"
        @subpronoun = "she"
        send "You pray to the baby seal gods and are granted a vagina!"
        other_players.each { |p| p.send "#{name} prays to the baby seal gods real hard and is granted a vagina!"}
      elsif gend == "neuter"
        @pospronoun = "its"
        @objpronoun = "it"
        @subpronoun = "it"
        send "You pray to the baby seal gods and are granted a smooth, plastic, groinal nub!"
        other_players.each { |p| p.send "#{name} prays to the baby seal gods real hard and is granted a smooth, plastic, groinal nub!"}
      end
    end      

    def method_missing(method, *args, &block)
      if method.to_s =~ /^act_(.+)/
        @room.players.each do |observer|
          c = Context.new :subject => self, :target => args.first, :verb => $1, :observer => observer
          observer.send block.call(c)
        end
      else
        super method, *args, &block
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
