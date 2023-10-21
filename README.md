# wc3_protocol
![Gem](https://img.shields.io/gem/v/wc3_protocol?color=default&style=plastic&logo=ruby&logoColor=red)
![Gem](https://img.shields.io/gem/dt/wc3_protocol?color=blue&style=plastic)
[![License: MIT](https://img.shields.io/badge/License-MIT-gold.svg?style=plastic&logo=mit)](LICENSE)

> The ruby gem to find and retrieve information of Warcraft3 games

# Contents

* [Usage](#usage)
* [Installation](#installation)
* [Documentation](#documentation)
* [Contributing](#contributing)




<a name="usage"></a>
## Usage

### Find games in LAN
```ruby
require 'wc3_protocol'

# examples with explicit default parameters
games = Wc3Protocol::Broadcast.find_games port: 6112, version: '1.27', game_type: 'TFT'
# => [Wc3Protocol::ServerInfo, Wc3Protocol::ServerInfo, ...]

games.each do |g|
  puts "=================================================="
  puts "Found game on #{g.remote_address}:#{g.remote_port}"
  puts
  puts "Type: #{g.game_type}"
  puts "Version: #{g.game_version}"
  puts "Name: #{g.name}"
  puts "Map: #{g.map_name}"
  puts "Players: #{g.taken_slots}/#{g.max_slots}"
  puts
  # =================================================="
  # Found game on 192.168.178.20:6112"
  # 
  # Type: The Frozen Throne
  # Version: 1.27
  # Name: Local game (SuperPlayer)
  # Map: (4)Tanaris.w3x
  # Players: 3/4"
  # 
end

```


<a name="installation"></a>
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wc3_protocol'
```

And then execute:

    $ bundle install

Or install it yourself by:

    $ gem install wc3_protocol




  
<a name="documentation"></a>    
## Documentation
Check out the doc at RubyDoc
<a href="https://www.rubydoc.info/gems/wc3_protocol">https://www.rubydoc.info/gems/wc3_protocol</a>





<a name="contributing"></a>    
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magynhard/wc3_protocol. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

