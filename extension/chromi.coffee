
# #####################################################################
# Configurables ...

config =
  host: "localhost" # For URI of server.
  port: "7441"      # For URI of server.
  path: ""          # For URI of server.
  beat:  5000       # Heartbeat frequency in milliseconds.
                    # Also, recovery interval in event of dropped socket.

# #####################################################################
# Constants and utilities.

# Messages from client to server begin with `chromi`, those from server to client with `chromiCap`.
chromi    = "chromi"
chromiCap = "Chromi"

echo      = (msg) -> console.log msg
idRegExp  = new RegExp "^\\d+$"
validId   = (id) -> id and idRegExp.test id

# #####################################################################
# Socket response class.

class Respond
  constructor: (sock) -> @sock = sock
  done: (id, msg) -> @send "done",  id, msg
  info: (id, msg) -> @send "info",  id, msg
  error: (id, msg) -> @send "error", id, msg

  send: (type, id, msg) ->
    id = "?" unless id
    if @send
      @sock.send [ chromiCap, id, "#{type}" ].concat(msg).map(encodeURIComponent).join " "
    else
      echo "#{me}: sending without a socket?"

# #####################################################################
# Handler.

handler = (respond, id, msg) ->
  if msg.length == 1 # and msg[0] == "[]"
    # Ping.
    return respond.done id, [ JSON.stringify [ true ] ]
  if msg.length isnt 2
    # Invalid request.
    return respond.error id, "invalid request:".split(/\s/).concat msg
  [ method, json ] = msg
  if not method
    return respond.error id, "no method:".split(/\s/).concat msg
  # Locate function.
  # Follow path from `window`.
  self = func = window
  for term in method.split "."
    self = func
    func = func?[term] if term
  # Do we have a function?
  if not func
    return respond.error id, "could not find function".split(/\s/).concat [method]
  # Parse JSON/argument.
  try
    args = JSON.parse json
  catch error
    return respond.error id, "JSON parse".split(/\s/).concat [json]
  # Call function.
  try
    # Add callback.
    args.push (stuff...) -> respond.done id, [ JSON.stringify stuff ]
    # Call function.
    func.apply self, args
  catch error
    error = JSON.stringify error
    return respond.error id, "call".split(/\s/).concat [method, json, error]

# #####################################################################
# The web socket.

serverCount = 0

class WebsocketWrapper
  count: 0

  constructor: ->
    echo "#{chromiCap} starting #{++serverCount}"
    return unless "WebSocket" of window
    return unless @sock = new WebSocket "ws://#{config.host}:#{config.port}/"
    # Initialisation.
    @sock.onopen = =>
      echo "       connected"
      @respond = new Respond @sock
      @respond.info "", [ "connect" ]
      @interval = setInterval ( => @respond.info "", [ "heartbeat", ++@count ] ), config.beat
    # Message handling.
    @sock.onmessage = (event) =>
      msg = event.data.split(/\s+/).filter((c) -> c).map decodeURIComponent
      [ signal, id ] = msg.splice(0,2)
      return handler @respond, id, msg if signal == chromi and validId id
    # Error/close handling.
    @sock.onerror = => @sock.close()
    @sock.onclose = => @close()

  # Clean up and, after a brief interval, attempt to reconnect.
  close: ->
    clearInterval @interval if @interval
    [ "interval", "respond", "sock" ].forEach (f) => delete @[f]
    setTimeout ( -> ws = new WebsocketWrapper() ), config.beat

# #####################################################################
# Start ...

ws = new WebsocketWrapper()

