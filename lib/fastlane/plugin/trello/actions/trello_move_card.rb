require 'fastlane/action'
require 'uri'
require 'net/http'
require 'json'
require_relative '../helper/trello_helper'

module Fastlane
  module Actions
    class TrelloMoveCardAction < Action
      
      @base_path = "https://api.trello.com/1"
      @base_url = URI(@base_path)
      @http = Net::HTTP.new(@base_url.host, @base_url.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      def self.run(params)
        
        @key = params[:api_key]
        @token = params[:api_token]
        @board_id = params[:board_id]
        list_name = params[:list_name]
        card_number = params[:card_number]
        
        UI.message("Fetching Trello list '#{list_name}'...")
        list = find_list_by(name: list_name)
        unless list
          UI.error("List #{list_name} not found.")
          return
        end
        list_id = list["id"]
        
        UI.message("Fetching Trello card [##{card_number}]...")
        card = find_card_by(short_id: card_number)
        unless card
          UI.error("Card #{card_number} not found.")
          return
        end
        card_name = card["name"]

        UI.message("Moving card [##{card_number}] '#{card_name}' to list '#{list_name}'")
        move_card(card_id: card["id"], list_id: list_id)
      end
      
      def self.find_list_by(name:)        
        url = URI("#{@base_path}/boards/#{@board_id}/lists?fields=id%2Cname&cards=none&card_fields=all&filter=open&key=#{@key}&token=#{@token}")
        request = Net::HTTP::Get.new(url)
        response = @http.request(request)
        lists = JSON.parse(response.body)
        list = lists.find { |list| list["name"] == name }
        return list
      end
      
      def self.find_card_by(short_id:)       
        url = URI("#{@base_path}/boards/#{@board_id}/cards/#{short_id}?fields=id%2Cname&key=#{@key}&token=#{@token}")
        request = Net::HTTP::Get.new(url)
        response = @http.request(request)
        card = JSON.parse(response.body)
        return card
      end
      
      def self.move_card(card_id:, list_id:)
        url = URI("#{@base_path}/cards/#{card_id}?idList=#{list_id}&key=#{@key}&token=#{@token}")
        request = Net::HTTP::Put.new(url)
        response = @http.request(request)
        card = JSON.parse(response.body)
        return card
      end

      def self.description
        "Trello plugin for Fastlane"
      end

      def self.authors
        ["Oscar De Moya"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Plugin for moving a trello card to a given list"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "TRELLO_API_KEY",
                                       description: "Trello API Key (get one at: https://trello.com/app-key)",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "TRELLO_API_TOKEN",
                                       description: "Trello API Token (get one at: https://trello.com/app-key)",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :board_id,
                                       env_name: "TRELLO_BOARD_ID",
                                       description: "The ID of the Trello board. You can find it in the trello board URL",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :list_name,
                                       env_name: "TRELLO_LIST_NAME",
                                       description: "The name of the list to move the card",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :card_number,
                                       env_name: "TRELLO_CARD_NUMBER",
                                       description: "The number of the card to be moved the given list",
                                       optional: false,
                                       type: Integer)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
