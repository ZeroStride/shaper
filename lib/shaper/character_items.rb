#require 'json'
require 'httparty'

module Shaper
  class CharacterItems
    include HTTParty

    def initialize(account_name, character)
      @account_name = account_name
      @character = character

      cookie = CookieHash.new
      cookie.add_cookies(Shaper::Auth)
      response = self.class.get(
        "https://www.pathofexile.com/character-window/get-items?accountName=#{account_name}&character=#{character}",
        headers: { 'Cookie' => cookie.to_cookie_string }
      )
      # TODO: Check response for 403 etc

      @raw_items = response["items"]

      @raw_gems = []
      @gems = {}
      @raw_items.each { |i| not i["socketedItems"].empty? }.collect do |item|
        item["socketedItems"].each do |gem|
          @raw_gems << gem

          @gems[gem["typeLine"]] ||= []
          @gems[gem["typeLine"]] << {
            socketed_in: Shaper::Parse.inventory_id(item["inventoryId"])
          }
        end
      end

      puts @gems.inspect
    end
  end
end
