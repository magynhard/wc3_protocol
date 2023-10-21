module Wc3Protocol

  class ServerInfo
    attr_reader :name
    attr_reader :taken_slots
    attr_reader :max_slots
    attr_reader :map_name

    attr_reader :game_type
    attr_reader :game_version

    attr_reader :remote_address
    attr_reader :remote_port

    # @param [Wc3Protocol::Message] message
    def initialize(message)
      @name = message.game_name
      @taken_slots = message.game_number_of_slots - message.game_remaining_slots
      @max_slots = message.game_number_of_slots
      @map_name = message.game_map_name
      @remote_address = message.sender_ip_address
      @remote_port = message.sender_port
      @game_version = message.game_version
      @game_type = message.game_type
    end
  end

end