module MUD
  module Connection
    def post_init
      send_data("Login: ")
    end

    def receive_data(data)
      if @player
        ### ' SaY hello WORld ' --> 'say', 'hello WORld'
        match = data.strip.match(/(\w*)\s*(.*)/)
        cmd  = match[1].downcase
        arg  = match[2] if match[2] != ""
        @player.command cmd, arg
      else
        @player = MUD::Player.new data.strip.capitalize, self
        @player.to_room(MUD::StartRoom)  #this is the only time we'll have MUD::Room, dammit. this is the only magical room!
      end
    end
  end
end
