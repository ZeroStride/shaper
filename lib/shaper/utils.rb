module Shaper
  class Parse
    def self.inventory_id(inventory_id)
      case inventory_id
      when "Weapon", "Weapon2"
        :main_hand
      when "Offhand", "Offhand2"
        :off_hand
      when "Ring"
        :right_ring
      when "Ring2"
        :left_ring
      else
        inventory_id.gsub(/\s+/, "_").downcase.to_sym
      end
    end

    def self.item_property_name(item_property)
      case item_property["name"]
      when /^.*[,].*$/
        :tags
      else
        item_property["name"].gsub(/\s+/, "_").downcase.to_sym
      end
    end

    def self.socketed_item(socketed_item)
      {
        support: socketed_item["support"],
        name: socketed_item["typeLine"]
      }.merge(socketed_item["properties"].select { |prop|
        [:quality, :level, :tags].include? Shaper::Parse.item_property_name(prop)
      }.collect { |prop|
        case Shaper::Parse.item_property_name(prop)
        when :tags
          [
            :tags,
            prop["name"].split(",").map(&:strip).map(&:downcase).map(&:to_sym)
          ]
        when :level, :quality
          [
            Shaper::Parse.item_property_name(prop),
            prop["values"][0][0].gsub(/[^\d,\.]/, '').to_i
          ]
        else
          [
            Shaper::Parse.item_property_name(prop),
            prop["values"][0][0]
          ]
        end
      }.concat(socketed_item["properties"].select { |prop|
        [:experience].include? Shaper::Parse.item_property_name(prop)
      }).to_h).merge(if not socketed_item.key?("additionalProperties") then {} else
        socketed_item["additionalProperties"].select { |prop|
          [:experience].include? Shaper::Parse.item_property_name(prop)
        }.collect { |prop|
          [
            :experience,
            42
          ]
        }.to_h
      end)
    end
  end
end
