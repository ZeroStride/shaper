require 'httparty'

module Shaper
  class Character
    include HTTParty

    attr_accessor :inventory, :name, :league, :passives, :level, :classs

    def initialize(account_name, character_name)
      @name = character_name

      cookie = CookieHash.new
      cookie.add_cookies(Shaper::Auth)
      response = self.class.get(
        "https://www.pathofexile.com/character-window/get-characters?accountName=#{account_name}",
        headers: { 'Cookie' => cookie.to_cookie_string }
      )
      # TODO: Check response for 403 etc

      # Find character
      found_character = response.select { |character| character["name"] == character_name }
      throw "Character not found" if found_character.empty?
      found_character = found_character.first

      # Properties 
      @league = found_character["league"]
      @level = found_character["level"]
      @classs = found_character["class"]
      #@classs = [].select { |class_id| class_id == found_character["classId"] }

      @inventory = CharacterItems.new(account_name, character_name)
      @passives = Passives.new(account_name, character_name)
    end
  end
end
