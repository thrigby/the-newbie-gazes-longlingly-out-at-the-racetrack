module MUD
  class MagicalItem
    attr_accessor :name, :color, :item

    def initialize(name, color)
      @name = name
      @color = color
      @item = "a #{color} #{name}"     
    end
    
    def to_s
      "a #{color} #{name}"      
    end
  end
end
