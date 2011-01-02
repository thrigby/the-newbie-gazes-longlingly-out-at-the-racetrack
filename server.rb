$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib/")

require 'eventmachine'
require 'mud'

EventMachine::run do
  EventMachine::start_server "0.0.0.0", MUD::Port, MUD::Connection
  puts "Started #{MUD::Brand} Server. To connect use 'telnet 0.0.0.0 #{MUD::Port}'"
end

cold me
