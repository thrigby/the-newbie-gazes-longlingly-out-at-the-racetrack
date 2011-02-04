module MUD
  class Player
    include Commands
    attr_accessor :name, :hp, :vit, :con, :dirty, :bounce, :wear, :inv, :gender, :blubber, :bead, :pluck, :cute, :whisker, :embed, :wield, :attack_power, :defense_power, :fighting, :cranium, :ribcage, :eye, :flipper, :tail, :exp, :type, :berserk, :autowield
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
      @autowield = true
      @fighting = nil
      @exp = 0
      @position = :flop
      @readytoblow = false
      send "Welcome #{name}! You are a baby seal!"
      prompt
    end

    def to_room(number)
      if @room
        other_players.each { |p| p.send "#{name} has left." }
        @room.players.delete self
      end

      @room = number
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
        "un" => "unwield",
#        "rb" => "ripback"    
      }
    end
    
    def command(cmd, arg)
      cmd = aliases[cmd] if aliases[cmd]
      begin
        @dirty = true
        case cmd
          when "pirate"; do_pirate
          when "ripback"; do_ripback(arg)
          when "zombie"; do_zombie
          when "berserker"; do_berserker
          when "autowield"; do_autowield
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
          when "west"; do_west
        
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
      if @berserk == false
        false
      else
        true
      end
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
