#=> evtl. mapping-tabelle von allen map-files erstellen und in server-info integrieren

# dir muss wc3-ordner mit files sein
Dir['*'].each do |f|
  # Öffne die Binärdatei im Binärmodus
  #file_path = '(8)Plaguelands.w3m'
  file_path = f
  next if File.directory?(f)
  binary_data = File.read(file_path, mode: 'rb')

  # Lese die notwendigen Daten
  magic_header = binary_data[0, 4]
  unknown_int = binary_data[4, 4].unpack('V').first
  map_name_length = binary_data[8, 4].unpack('V').first
  map_name = binary_data[8, 30].force_encoding('UTF-8')

  # Gib den Map-Namen aus
  puts %Q<Map Name: #{map_name[0..(map_name.index("\0"))]}>
end