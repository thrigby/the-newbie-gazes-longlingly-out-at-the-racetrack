require 'eventmachine'

module MUD
  Brand   = "BABY SEAL MUD!"
  Port    = 8888
  Players = []
  
  class Player
    attr_accessor :name, :hp, :vit, :con, :dirty, :bounce

    def initialize(name, con)
      @name = name
      @con = con
      @hp = 10
      @vit = 12
      @dirty = true
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
        when "make"; do_make(arg)
        when ""; ## do_nothing
        when "bounce"; do_bounce
        when "flop"; do_flop
        else ; send "Unknown Command: '#{cmd}'. Type 'help' for commands."
      end
      MUD::Players.each { |p| p.prompt if p.dirty }
    end

    def do_look
      send "THE ARCTIC"
      send "You are on a beautiful, icy, rocky beach."
      send " [------]"
      other_players.each { |p| send "#{p.name} is here." }
    end

    def do_say(message)
      send "You say '#{message}'"
      other_players.each { |p| p.send "#{name} says '#{message}'" }
    end

    def do_exit
      send "A Polar Bear Eats You!"
      other_players.each { |p| p.send "#{name} was dragged away by a polar bear!"}
      con.close_connection_after_writing
      MUD::Players.delete self
    end

    def do_help
      send "Commands: say, look, exit, help, make, bounce, flop"
    end
    
    def do_make(thing)
      send "You make a beautiful #{thing}"
      other_players.each { |p| p.send "#{name} builds a beautiful #{thing}" }
    end

    def do_bounce
      send "You start bouncing up and down!"
      other_players.each { |p| p.send "#{name} starts bouncing up and down!"}
    end

    def prompt
      con.send_data "h:#{hp} v:#{vit}> "
      @dirty = false
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
