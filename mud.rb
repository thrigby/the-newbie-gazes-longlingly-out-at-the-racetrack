require 'eventmachine'

#push, pop, rdoc, detect

module MUD
  Brand = "BABY SEAL MUD!"
  Port = 8888
  Players = []
  Room = {:bubblegum => 0, :item => []}
 
  class Player
    attr_accessor :name, :hp, :vit, :con, :dirty, :bounce

    def initialize(name, con)
      @name = name
      @con = con
      @hp = 10
      @vit = 12
      @dirty = true
      @inventorybg = 0
      @position = true
      @readytoblow = false
#      Inv = {:item => []}     #internal player inventory array
      MUD::Players << self
      send "Welcome #{name}! You are a baby seal!"
      other_players.each { |p| p.send "#{name} has arrived." }
      prompt
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
      MUD::Players.reject { |p| p == self }
    end

    def command(cmd, arg)
      @dirty = true
      case cmd
        when "say"; do_say(arg)
        when "look"; do_look
        when "exit"; do_exit
        when "help"; do_help
        when "chew"; do_chew
        when ""; ## do_nothing
        when "bounce"; do_bounce
        when "flop"; do_flop
        when "get"; do_get
        when "blow"; do_blow
        when "inventory"; do_inventory
        else ; send "Unknown Command: '#{cmd}'. Type 'help' for commands."
      end
      MUD::Players.each { |p| p.prompt if p.dirty }
    end

    def do_look
      send "THE ARCTIC"
      send "You are on a beautiful, icy, rocky beach."
      send "#{Room[:bubblegum]} pieces of bubblegum sit here."
      send " [------]"
      other_players.each { |p| send "#{p.name} is here." }
      Room[:item].each { |m| send "A #{m.itemcolor} #{m.itemname} is here."}
    end

    def do_say(message)
      send "You say '#{message}'"
      other_players.each { |p| p.send "#{name} says '#{message}'" }
    end

    def do_exit
      send "A Polar Bear Eats You!"
      other_players.each { |p| p.send "#{name} was dragged away by a polar bear!" }
      con.close_connection_after_writing
      MUD::Players.delete self
    end

    def do_help
      send "Commands: say, look, exit, help, make, bounce, flop, blow"
    end

   

    def do_bounce
      send "You start bouncing up and down!"
      other_players.each { |p| p.send "#{name} starts bouncing up and down!"}
      bouncygum = rand(4) + 1   
      Room[:bubblegum] += bouncygum
      @position = false
      send "You make #{bouncygum} magic pieces of bubblegum!"
      other_players.each { |p| p.send "#{name} makes #{bouncygum} magic pieces of bubblegum!" }  
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
   
    def do_blow
      unless @readytoblow
        send "You must chew the bubblegum before you can blow a bubble!"
      else
        send "You blow a bright red, magic bubble until it POPS!"
        other_players.each { |p| p.send "#{name} blows a bright red magic bubble until it POPS!"}
        @readytoblow = false
          color = ["red", "green", "blue", "crucified", "bloody", "rusty", "used", "rancid", "holy", "rubber", "ragged", "angry", "moldy"]
          cc = color[rand(color.size)]
          toy = ["gimp suit", "condom", "needle", "raincloud", "dwarven battleaxe +12", "box jellyfish", "polar bear chew toy", "cardboard-cutout of Matthew McConaughey", "inflatable Silvia Plath doll", "monkey", "battle-robot", "stuffed-animal yeti", "home-liposuction kit"]
          tt = toy[rand(toy.size)]
          send "A #{cc} #{tt} appears!"
          other_players.each { |p| p.send "A #{cc} #{tt} appears!"}   
          Room[:item] << MagicalItem.new("#{tt}", "#{cc}")       
      end
    end 

    def do_get
      if Room[:bubblegum] == 0
        send "There is no bubblegum here!"
      else
        send "You pick up a piece of magical bubblegum."
        other_players.each { |p| p.send "#{name} picks up a piece of magical bubblegum."}
        @inventorybg += 1
        Room[:bubblegum] -= 1
      end
    end
   
    def do_flop
      send "You grunt adorably as you flop down on the ground to rest."
      other_players.each { |p| p.send "#{name} flops down onto the ground with an adorable little grunt."}
      @position = true
    end

    def prompt
      con.send_data "h:#{hp} v:#{vit}> "
      @dirty = false
    end

    def do_inventory
      send "you look in your fannypack! you have #{@inventorybg} pieces of bubblegum!"
    end     
  end

  class MagicalItem
    attr_accessor :itemname, :itemcolor

    def initialize(itemname, itemcolor)
      @itemname = itemname
      @itemcolor = itemcolor
    end
  end
  
  module Connection
    def post_init
      send_data("Login: ")
    end

    def receive_data(data)
      if @player
        ### ' SaY hello WORld ' --> 'say', 'hello WORld'
        match = data.strip.match(/(\w*)\s*(.*)/)
        @player.command match[1].downcase, match[2]
      else
        @player = MUD::Player.new data.strip.capitalize, self
      end
    end
  end
end

EventMachine::run do
  EventMachine::start_server "0.0.0.0", MUD::Port, MUD::Connection
  puts "Started #{MUD::Brand} Server. To connect use 'telnet 0.0.0.0 #{MUD::Port}'"
end