module MUD
  class MagicalItem
    attr_accessor :name, :color, :item

    def initialize(name, color)
      @name = name
      @color = color
      # orion: this seems strangely redundant to have item with @item
      @item = "#{color} #{name}"     
    end
    
    def to_s
      "a #{color} #{name}"      
    end
  end
end
