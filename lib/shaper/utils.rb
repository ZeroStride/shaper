module Shaper
  class Parse
    def self.inventory_id(inventory_id)
      case inventory_id
      when "Weapon", "Weapon2"
        :main_hand
      when "Offhand", "Offhand2"
        :off_hand
      when "Helm"
        :helm
      when "BodyArmour"
        :chest
      when "Gloves"
        :gloves
      when "Boots"
        :boots
      when "Amulet"
        :amulet
      when "Ring"    # TODO: is right/left correct?
        :right_ring
      when "Ring2"
        :left_ring
      when "Belt"
        :belt
      end
    end
  end
end
