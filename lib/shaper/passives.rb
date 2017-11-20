require 'httparty'

module Shaper
  class Passives
    include HTTParty

    attr_accessor :skills

    def initialize(account_name, character_name)
      cookie = CookieHash.new
      cookie.add_cookies(Shaper::Auth)
      response = self.class.get(
        "https://www.pathofexile.com/character-window/get-passive-skills?character=#{character_name}&accountName=#{account_name}",
        headers: { 'Cookie' => cookie.to_cookie_string }
      )
      # TODO: Check response for 403 etc

      @skills = response["hashes"]
    end
  end
end
