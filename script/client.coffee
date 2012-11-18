
args      = require "optimist" 
args      = args.usage "Usage: $0 [--port=PORT] [--server=SERVER]" 
args      = args.default "port", 7441 
args      = args.default "server", "localhost" 
args      = args.argv

WS        = require "ws"
ws        = new WS("ws://#{args.server}:#{args.port}/")
id        = Math.floor Math.random() * 2000000000

chromi    = "chromi"
chromiCap = "Chromi"
msg       = args._.map(encodeURIComponent).join " "

echo = (msg, where = process.stdout) ->
  msg = msg.join(" ") if typeof(msg) isnt "string"
  where.write "#{msg}\n"

echoErr = (msg, die = false) ->
  echo msg, process.stderr
  process.exit 1 if die

ws.on "open", -> ws.send "#{chromi} #{id} #{msg}"

ws.on "message",
  (m) ->
    msg = m.split(/\s+/).map(decodeURIComponent)
    [ signal, anId, type ] = msg
    return unless signal == chromiCap and anId == id.toString()
    switch type
      when "info"
        echoErr msg
      when "done"
        echo msg.splice 3
        process.exit 0
      when "error"
        echoErr msg, true
        process.exit 1
      else
        echoErr msg
        echo msg

