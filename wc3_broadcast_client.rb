require 'socket'

# Open socket
udp_socket = UDPSocket.new
udp_socket.bind('0.0.0.0', 6112)

puts "Listening for broadcasts on port 6112..."

BYTES_MAGIC_BYTE = {
  'f7' => 'Local Area Network',
  'ff' => 'Battle.net'
}
BYTES_OP_CODE_BYTE = {
  '2f' => 'LAN_GAME_QUERY',
  '30' => 'GAME_INFORMATION',
  '31' => 'GAME_CREATED',
  '32' => 'PLAYERS_CHANGED',
  '33' => 'GAME_CANCELLED',
  '01' => 'KEEP_ALIVE',
  '04' => 'JOINED_PLAYER_INFORMATION',
  '06' => 'PLAYER_INFO',
  '07' => 'PLAYER_LEFT_GAME',
  '08' => 'PLAYER_LOADED_GAME',
  '09' => 'SLOTS_CHANGED',
  '0a' => 'HOST_STARTED_GAME',
  '0b' => 'START_LOADING_INFO',
  '0f' => 'CHAT_RECEIVERS',
  # TODO: more
}
BYTES_GAME_TYPES = {
  'W3XP' => 'The Frozen Throne',
  'WAR3' => 'Realms of Chaos'
}

def game_parser(message)
  bytes = message.bytes
  magic_byte = bytes[0].to_s(16)
  op_code = bytes[1].to_s(16)
  packet_length = (bytes[2..3].map { |p| p.to_s(16) }).to_i
  game_type = (bytes[4..7].map { |p| p.to_s(16) })

  {
    connection_type: if magic_byte == 'f7'
                       'LAN'
                     elsif magic_byte == 'ff'
                       'BATTLE.NET'
                     end,

  }
end


def request_for_lan_games(udp_socket)
  # request for games
  broadcast_address = '255.255.255.255'
  broadcast_port = 6112

  # broadcast to ask for TFT games
  data_to_send = [
    "0xf7".to_i(16),
    "0x2f".to_i(16),
    *[16,0],
    *"W3XP".reverse.bytes,
    *[27, 0, 0, 0],
    *[0, 0, 0, 0],
  ]

  puts "DATA: #{data_to_send.inspect}"

  data_to_send = data_to_send.pack('C*')

  begin
    #udp_socket = UDPSocket.new
    udp_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    udp_socket.send(data_to_send, 0, broadcast_address, broadcast_port)
  ensure
    #udp_socket.close if udp_socket
  end
end

request_for_lan_games udp_socket

loop do
  # Wait for message
  message, sender_info = udp_socket.recvfrom(1024)

  # output response
  # puts "Received broadcast: #{message}"
  # puts "Received broadcast11: #{message.bytes.map { |i| i.to_s(16) }}"
  # puts "Received broadcast1: #{message.bytes.pack("c*").unpack("H*").first}"
  # puts "Received broadcast2: #{sender_info}"
  # puts "size: #{message.size}"
  # puts "text: #{message}"

  puts

  bytes = message.bytes
  hex_bytes = bytes.map { |p| p.to_s(16) }

  magic_byte = BYTES_MAGIC_BYTE[bytes[0].to_s(16)]
  op_code = [bytes[1]].pack('C').unpack('C')[0].to_s(16)
  packet_length = bytes[2..3].pack('C*').unpack('S<')[0]
  game_type = BYTES_GAME_TYPES[(message[4..7]).to_s.reverse]
  game_version = "1." + bytes[8..11].pack('C*').unpack('L<')[0].to_s
  game_id = bytes[12..15].pack('C*').unpack('L<')[0]
  system_tick_counts = nil
  game_info_string = ""
  number_of_slots = nil
  game_flags = nil
  player_slots = nil
  non_computer_slots = nil
  computer_or_closed_slots = nil
  remaining_slots = nil
  filled_slots = nil
  unknown = nil
  tcp_game_port = nil
  game_flag = nil
  if op_code == '30'
    system_tick_counts = bytes[16..19].pack('C*').unpack('L<')[0]
    null_termination_index = bytes[20..-1].index(0)
    if null_termination_index
      null_termination_index += 20
      game_info_string = bytes[20..null_termination_index].pack('C*').unpack('Z*')[0]
    end
    number_of_slots = bytes[null_termination_index+1..null_termination_index+4]#.pack('C*').unpack('L<')[0]
    number_of_slots = bytes[-22..-19].pack('C*').unpack('L<')[0]
    game_flags = bytes[-18..-15].pack('C*').unpack('L<')[0]
    player_slots = bytes[-14..-11].pack('C*').unpack('L<')[0]
    non_computer_slots = bytes[-10..-7].pack('C*').unpack('L<')[0]
    computer_or_closed_slots = number_of_slots - non_computer_slots
    remaining_slots = number_of_slots - computer_or_closed_slots - player_slots
    filled_slots = computer_or_closed_slots + player_slots
    unknown = bytes[-6..-3].pack('C*').unpack('L<')[0]
    tcp_game_port = bytes[-2..-1].pack('C*').unpack('S<')[0]
  end

  puts
  puts "===================================================0"
  puts "SENDER: #{sender_info}"
  puts "BYTES: #{bytes}"
  puts "HEX BYTES: #{hex_bytes}"
  puts
  puts "MAGIC BYTE: #{magic_byte}"
  puts "OP CODE: #{op_code}"
  puts "PACKET LENGTH: #{packet_length}"
  puts "GAME TYPE: #{game_type}"
  puts "GAME VERSION: #{game_version}"
  puts "GAME ID: #{game_id}"
  puts "UPTIME: #{system_tick_counts} / #{system_tick_counts.to_i/1000/60/60} hours"
  puts "GAME INFO: #{game_info_string}"
  puts "null index: #{null_termination_index}"
  puts "NUMBER OF SLOTS: #{number_of_slots}"
  puts "GAME FLAGS: #{game_flags}"
  puts "PLAYER SLOTS: #{player_slots}"
  puts "NON COMPUTER SLOTS: #{non_computer_slots}"
  puts "COMPUTER OR CLOSED SLOTS: #{computer_or_closed_slots}"
  puts "REMAINING SLOTS: #{remaining_slots}"
  puts "FILLED SLOTS: #{filled_slots}"
  puts "UNKNOWN: #{unknown}"
  puts "TCP GAME PORT: #{tcp_game_port}"

  # break
end