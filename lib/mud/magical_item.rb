module MUD
  class MagicalItem
    attr_accessor :name, :color, :item

    @@item_sets = {
      :basic => [
        {
          :color => [ "red-painted", "green-painted", "blue-painted", "bloody",
                      "rusty", "used", "rancid", "holy", "rubber", "ragged", "moldy",
                      "tasteful", "ceremonial", "shag-carpeted", "dusty", "rotting",
                      "solid-gold"
                    ],
          :name =>  [ "gimp suit", "stapler", "needle", "raincloud", "superman suit",
                      "box jellyfish", "polar bear chew toy",
                      "cardboard-cutout of Matthew McConaughey", "balloon", "harpoon",
                      "battle-robot", "toy yeti", "home-liposuction kit",
                      "polar-bear pelt", "jar of pickles", "batman cowl", "pixie wings",
                      "hula-hoop", "glow sticks", "shrunken head", "vader helmet",
                      "wonder-woman suit", "teacup", "dead baby seal",
                      "Lady Liberty crown and torch", "collectable spoon", "witch's hat",
                      "twelve-gauge shotgun", "piece of Einstein's brain",
                      "talking stick", "tommygun", "underwood typewriter",
                      "boquet of roses", "umbrella", "ring of power",
                      "inflatable Silvia Plath doll"
                    ]
        }
      ],
      :bazerker => [ {
        :color => ["shag-carpeted", "leopard-print-upholstered ", "massive, horned", "cute little plush"],
        :name => ["GWAR battle helmet", "viking dragonhelm", "football helmet"]
        }, {
        :color => ["shag-carpeted", "leopard-print-upholstered", "massive, horned", "cute little plush squeezy-toy"],
        :name => ["Epiphone Goth 1958 Explorer Electric Guitar", "Gibson Explorer covered in duck stickers", "1982 Casio ROM Keyboard MT-18"]
      } ],
      :pirate => [ {
        :color => ["mangy", "salt water taffy", "barnacled", "rusty"],
        :name => ["eye patch", "parrot", "peg leg", "bottle of grog", "pirate hat"]
      } ]
    }


    def initialize(name, color)
      @name = name
      @color = color
      # orion: this seems strangely redundant to have item with @item
      @item = "#{color} #{name}"     
    end

    def self.item_set( set )
      items = []
      @@item_sets[set].each do |item|
        cc = item[:color][rand(item[:color].size)]
        puts cc.inspect
        tt = item[:name][rand(item[:name].size)]
        puts tt.inspect
        items << MagicalItem.new(tt,cc)
      end
      return items
    end
    
    def self.bazerker_items
      item_set(:bazerker)
    end

    def self.pirate_items
      item_set(:pirate).join item_set(:pirate)
    end

    def self.random_toy
      item_set(:basic)[0]
    end

    def to_s
      "#{color} #{name}"      
    end

  end
end
