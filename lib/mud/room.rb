module MUD
  class Room
    attr_accessor :bubblegum, :item, :players, :desc, :title, :number
    
    def initialize (title, desc, number)
      @bubblegum = 0
      @item = []
      @players = []
      @desc = desc
      @title = title
      @number = 0 
    end      

    def add_item(item)
      @players.each { |p| p.send "#{item} appears!".capitalize }   
      @item << item
    end
    
    def add_corpse(item)
      @players.each { |p| p.send "The #{item} flips through the air and lands on the ground.".capitalize}  
      @item << item
    end
  end  
end
