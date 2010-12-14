module MUD
  class MagicalItem
    attr_accessor :itemname, :itemcolor

    def initialize(itemname, itemcolor)
      @itemname = itemname
      @itemcolor = itemcolor
    end
    
    def to_s
      "a #{itemcolor} #{itemname}"      
    end
  end
end
