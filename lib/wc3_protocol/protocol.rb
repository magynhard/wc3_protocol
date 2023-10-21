module Wc3Protocol
  module Protocol
    BYTE_MAGIC = {
      'f7' => 'LAN',
      'ff' => 'BATTLE_NET'
    }
    BYTE_OP_CODE = {
      '2f' => :LAN_GAME_QUERY,
      '30' => :GAME_INFORMATION,
      '31' => :GAME_CREATED,
      '32' => :PLAYERS_CHANGED,
      '33' => :GAME_CANCELLED,
      '01' => :KEEP_ALIVE,
      '04' => :JOINED_PLAYER_INFORMATION,
      '06' => :PLAYER_INFO,
      '07' => :PLAYER_LEFT_GAME,
      '08' => :PLAYER_LOADED_GAME,
      '09' => :SLOTS_CHANGED,
      '0a' => :HOST_STARTED_GAME,
      '0b' => :START_LOADING_INFO,
      '0f' => :CHAT_RECEIVERS,
      # TODO: more bytes available
    }
    BYTE_GAME_TYPE = {
      'W3XP' => 'The Frozen Throne',
      'WAR3' => 'Realms of Chaos'
    }
  end
end