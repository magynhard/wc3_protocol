require 'socket'

# Open socket
udp_socket = UDPSocket.new
udp_socket.bind('0.0.0.0', 6112)

puts "Listening for broadcasts on port 6112..."


BYTES_MAGIC_BYTE = {
  'f7' => 'Local Area Network',
  'ff' => 'Battle.net'
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


loop do
  # Wait for message
  message, _ = udp_socket.recvfrom(1024)

  # output response
  puts "Received broadcast: #{message}"
  puts "Received broadcast11: #{message.bytes.map { |i| i.to_s(16) }}"
  puts "Received broadcast1: #{message.bytes.pack("c*").unpack("H*").first}"
  puts "Received broadcast2: #{_}"
  puts "size: #{message.size}"
  puts "text: #{message}"

  puts

  bytes = message.bytes
  hex_bytes = bytes.map { |p| p.to_s(16) }

  magic_byte = BYTES_MAGIC_BYTE[bytes[0].to_s(16)]
  op_code = bytes[1].to_s(16)
  packet_length = hex_bytes[2..3].join('').to_i(16)
  game_type = BYTES_GAME_TYPES[(message[4..7]).to_s.reverse]
  game_version = bytes[8..11].map(&:to_s).select { "" }
  game_version = "1." + bytes[8..11].pack('C*').unpack('L<')[0].to_s

  puts "MAGIC BYTE: #{magic_byte}"
  puts "OP CODE: #{op_code}"
  puts "PACKET LENGTH: #{packet_length}"
  puts "GAME TYPE: #{game_type}"
  puts "GAME VERSION: #{game_version}"


  #break
end