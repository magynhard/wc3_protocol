require 'socket'
require 'stringio'
require 'timeout'
require 'ostruct'

require_relative 'protocol'

module Wc3Protocol

  class Broadcast

    GAME_TYPE = {
      'TFT' => 'W3XP',
      'ROC' => 'WAR3'
    }

    # @param [Integer] port
    # @param [String] version
    # @param ['ROC','TFT'] game_type
    # @return [Array<Wc3Protocol::ServerInfo>] server info of found games
    def self.find_games port: 6112, version: '1.27', game_type: 'TFT'
      _broadcast_request port: port, version: version, game_type: game_type
      # @type [Array<Wc3Protocol::Message>]
      messages = _broadcast_receive
      messages.select { |m| Protocol::BYTE_OP_CODE[m.op_code] == :GAME_INFORMATION }.map { |m| Wc3Protocol::ServerInfo.new(m) }
    end

    private

    def self._broadcast_request port:, version:, game_type:
      # Open socket and listen for broadcast messages
      @udp_socket = UDPSocket.new
      @udp_socket.bind('0.0.0.0', port)

      # request for games
      broadcast_address = '255.255.255.255'
      broadcast_port = 6112

      # we need only the minor from version for the broadcast
      version_integer = version.split('.').last.to_i
      game_type_bytes = GAME_TYPE[game_type].reverse.bytes # needs to be reversed because of little endian order(?)
      packet_size_byte = 16

      # broadcast to ask for TFT games
      data_to_send = [
        "0xf7".to_i(16),
        "0x2f".to_i(16),
        *[packet_size_byte, 0],
        *game_type_bytes,
        *[version_integer, 0, 0, 0],
        *[0, 0, 0, 0],
      ]

      data_to_send = data_to_send.pack('C*')

      begin
        @udp_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        @udp_socket.send(data_to_send, 0, broadcast_address, broadcast_port)
      ensure
        # udp_socket.close if udp_socket
      end
    end

    def self._broadcast_receive
      raw_messages = []
      waiting_timeout_seconds = 1
      begin
        Timeout.timeout(waiting_timeout_seconds) do
          loop do
            # Wait for message
            message, sender_info = @udp_socket.recvfrom(1024)
            raw_messages.push(OpenStruct.new message: message, sender_info: sender_info)
          end
        end
      rescue Timeout::Error
        # messages received until timeout
      end
      @udp_socket.close # ensure socket is closed after
      raw_messages.map { |m| Wc3Protocol::Message.new(raw_msg: m.message, raw_sender_info: m.sender_info) }
    end

  end
end