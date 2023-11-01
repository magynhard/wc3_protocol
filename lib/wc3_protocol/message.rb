require_relative 'protocol'

module Wc3Protocol

  class Message

    attr_reader :sender_address_family
    attr_reader :sender_port
    attr_reader :sender_hostname
    attr_reader :sender_ip_address

    attr_reader :raw_bytes
    attr_reader :raw_bytes_hex

    attr_reader :magic_byte
    attr_reader :op_code
    attr_reader :packet_size
    attr_reader :game_type
    attr_reader :game_version
    attr_reader :game_id
    attr_reader :tick_counts_ms
    attr_reader :game_settings
    attr_reader :game_name
    # attr_reader :zero_flag
    attr_reader :game_map_name
    attr_reader :game_map_width
    attr_reader :game_map_height
    attr_reader :game_number_of_slots
    attr_reader :game_flags
    attr_reader :game_player_slots
    attr_reader :game_non_computer_slots
    attr_reader :game_computer_or_closed_slots
    attr_reader :game_remaining_slots
    attr_reader :game_filled_slots
    # attr_reader :unknown_byte
    attr_reader :game_port

    def initialize(raw_msg:, raw_sender_info:)
      _parse_message raw_msg, raw_sender_info
    end

    def lan?
      !battle_net?
    end

    def battle_net?
      @magic_byte == 'ff'
    end

    private

    def _parse_message(msg, sender_info)
      @raw_bytes = msg.bytes
      @raw_hex_bytes = @raw_bytes.map { |p| p.to_s(16) }

      @magic_byte = Wc3Protocol::Protocol::BYTE_MAGIC[@raw_bytes[0].to_s(16)]
      @op_code = [@raw_bytes[1]].pack('C').unpack('C')[0].to_s(16)
      @packet_size = @raw_bytes[2..3].pack('C*').unpack('S<')[0]
      @game_type = Wc3Protocol::Protocol::BYTE_GAME_TYPE[(msg[4..7]).to_s.reverse]
      @game_version = "1." + @raw_bytes[8..11].pack('C*').unpack('L<')[0].to_s
      @game_id = @raw_bytes[12..15].pack('C*').unpack('L<')[0]

      @sender_address_family = sender_info[0]
      @sender_port = sender_info[1]
      @sender_hostname = sender_info[2]
      @sender_ip_address = sender_info[3]

      case @op_code
      when '2f'
        # do nothing, header only
      when '30'
        _parse_op_code_30
      else
        puts "WARNING: Unknown, unprocessed OP code #{@op_code}"
        # raise StandardError.new "Unknown Protocol Code"
      end
    end

    def _parse_op_code_30
      if op_code == '30'
        @tick_count_ms = @raw_bytes[16..19].pack('C*').unpack('L<')[0]
        game_info_bytes = @raw_bytes[20..-23]
        @game_settings = game_info_bytes[0..3].pack('C*').unpack('L<')[0]
        zero_flag = game_info_bytes[31]
        @game_name = _get_string_segment(@raw_bytes[20..-1])
        encoded_segment_start_index = 22 + _utf8_byte_count(@game_name)
        decrypted = _decode_string_part(@raw_bytes[encoded_segment_start_index..-1]).bytes
        @game_settings = decrypted[0..3].pack('C*').unpack('L<')[0]
        decrypted_string = decrypted.pack('C*')

        # extract map name from 14th byte
        @game_map_name = decrypted_string[13..-1]
        # cut string at NULL string termination byte
        @game_map_name = @game_map_name[0..@game_map_name.index("\x00")-1]

        # Get last segment of map name that is split by '\\'
        last_map_name_segment = @game_map_name.split('\\').last

        # use original map name if no segment is found
        @game_map_name = last_map_name_segment || @game_map_name

        @game_map_width = decrypted[5..-1].pack('C*').unpack('S<')[0]
        @game_map_height = decrypted[7..-1].pack('C*').unpack('S<')[0]

        game_info_string = decrypted
        @game_number_of_slots = @raw_bytes[-22..-19].pack('C*').unpack('L<')[0]
        @game_flags = @raw_bytes[-18..-15].pack('C*').unpack('L<')[0]
        @game_player_slots = @raw_bytes[-14..-11].pack('C*').unpack('L<')[0]
        @game_non_computer_slots = @raw_bytes[-10..-7].pack('C*').unpack('L<')[0]
        @game_computer_or_closed_slots = @game_number_of_slots - @game_non_computer_slots
        @game_remaining_slots = @game_number_of_slots - @game_computer_or_closed_slots - @game_player_slots
        @game_filled_slots = @game_computer_or_closed_slots + @game_player_slots
        unknown_byte = @raw_bytes[-6..-3].pack('C*').unpack('L<')[0]
        @game_port = @raw_bytes[-2..-1].pack('C*').unpack('S<')[0]
      end
    end

    def _decode_string_part(data)
      mask = 0
      memory_stream = StringIO.new

      first_zero_index = data.index(0)
      data_cut = first_zero_index.nil? ? data : data[0...first_zero_index]

      data_cut.each_with_index do |b, i|
        if i % 8 != 0
          if (mask & (1 << (i % 8))) == 0
            memory_stream.putc(b - 1)
          else
            memory_stream.putc(b)
          end
        else
          mask = b
        end
      end

      memory_stream.string
    end

    def _get_string_segment(data)
      first_zero_index = data.index(0)
      return '' if first_zero_index.nil?

      string_segment = data[0...first_zero_index]
      string_segment.pack('C*').force_encoding('UTF-8')
    end

    def _utf8_byte_count(string)
      utf8_string = string.encoding.name == 'UTF-8' ? string : string.encode('UTF-8')
      utf8_string.bytesize
    end

  end
end