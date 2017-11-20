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

      @gems = []
      @raw_gems = []
      @gems_by_name = {}
      @gems_by_slot = {}
      @raw_items.each { |i| not i["socketedItems"].empty? }.collect do |item|
        item["socketedItems"].each do |socketed_item|
          @raw_gems << socketed_item

          gem = Shaper::Parse.socketed_item(socketed_item).merge({
            socketed_in: Shaper::Parse.inventory_id(item["inventoryId"])
          })

          @gems << gem

          @gems_by_name[gem[:name]] ||= []
          @gems_by_name[gem[:name]] << gem.reject { |key, value| key == :name }

          @gems_by_slot[gem[:socketed_in]] ||= []
          @gems_by_slot[gem[:socketed_in]] << gem
        end
      end

      puts @gems_by_name.inspect
    end
  end
end
