module MUD
  class Player
    include Commands
    attr_accessor :name, :hp, :vit, :con, :dirty, :bounce, :wear

    def initialize(name, con)
      @name = name
      @hp = 10
      @con = con
      @vit = 12
      @dirty = true
      @inventorybg = 10
      @inv = []
      @wear = []
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
      @dirty = true
      case cmd
        when "flex"; do_flex(arg)
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
        when "i"; do_inventory
        when "glue"; do_glue
        else ; send "Unknown Command: '#{cmd}'. Type 'help' for commands."
      end
      @room.players.each { |p| p.prompt if p.dirty }
    end

    def find_player_by_name(name)  
      @room.players.detect { |p| p.name.downcase == name.downcase}
    end

    def do_dig_west
      new_room = Room.new "Ice Tunnel", "It's cold.", 2
      send "You use your baby seal magic powers and dig westward!"
      send "You have created a new room!"
      other_players.each { |p| p.send "#{name} digs a new room to the west."}
    end

    def do_exa(name)
      target = find_player_by_name(name)
      if target
        send "You examine #{target.name}."
        send "They have #{target.wear.size} things."
        target.wear.each do |item| 
          send "#{item}"
        end        
      else
        send "NOBODY HOME"
      end  
    end

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
          send "You carefully glue #{@inv[0]} to  #{@inv[1]} with your magical bubblegum."
          other_players.each { |p| p.send "#{name} carefully glues #{@inv[0]} to  #{@inv[1]} with his magical bubblegum."}         
          @inv << MagicalItem.new("glued to #{@inv.shift}","#{@inv.shift}")
        end  
      end
    end     
        
    def prompt
      con.send_data "h:#{hp} v:#{vit}> "
      @dirty = false
    end
  end
end

=begin
def attach(item)
 me:  you fixed my smile code
 Orion:  @attached = item
end
def to_s
if @attached
"#{@attached} glued to a #{color} #{name}"
else
"a #{color} #{name}"
end
en
 me:  ponder
 Orion:  oh wait it gets better
def attach(item)
if @attached
@attached.attach(item)
else
@attached = item
end
end
(if I already have an item attached to me - instead glue it to the item i'm attached to)
can create a list of items of any depth
also the to_s will show
 me:  hmmm
 Orion:  "a glued to b glued to c glued to d"
and dissassemble is easy

=end
