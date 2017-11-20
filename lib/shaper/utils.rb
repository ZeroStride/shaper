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

    def self.name_to_sym(item_property)
      case item_property["name"]
      when /^.*[,].*$/
        :tags
      else
        item_property["name"].gsub(/\s+/, "_").downcase.to_sym
      end
    end

    def self.socketed_item(socketed_item)
      {
        # Defaults that will get overwritten if the gem has the properties
        quality: 0,
        experience: 1.0,

        corrupted: socketed_item["corrupted"] || false,
        support: socketed_item["support"],
        name: socketed_item["typeLine"],
        requirements: {
          level:0,
          int:0,
          str:0,
          dex:0
        }.merge(socketed_item["requirements"].select { |requirement|
          if requirement["name"] then
            [:level, :int, :str, :dex].include? Shaper::Parse.name_to_sym(requirement)
          else
            false
          end
        }.collect { |requirement|
          [
            Shaper::Parse.name_to_sym(requirement),
            requirement["values"][0][0].to_i
          ]
        }.to_h)
      }.merge(socketed_item["properties"].select { |prop|
        [:quality, :level, :tags].include? Shaper::Parse.name_to_sym(prop)
      }.collect { |prop|
        case Shaper::Parse.name_to_sym(prop)
        when :tags
          [
            :tags,
            prop["name"].split(",").map(&:strip).map(&:downcase).map(&:to_sym)
          ]
        when :level, :quality
          [
            Shaper::Parse.name_to_sym(prop),
            prop["values"][0][0].gsub(/[^\d,\.]/, '').to_i
          ]
        else
          [
            Shaper::Parse.name_to_sym(prop),
            prop["values"][0][0]
          ]
        end
      }.concat(socketed_item["properties"].select { |prop|
        [:experience].include? Shaper::Parse.name_to_sym(prop)
      }).to_h).merge(if not socketed_item.key?("additionalProperties") then {} else
        socketed_item["additionalProperties"].select { |prop|
          [:experience].include? Shaper::Parse.name_to_sym(prop)
        }.collect { |prop|
          [
            :experience,
            prop["progress"]
          ]
        }.to_h
      end)
    end
  end
end
