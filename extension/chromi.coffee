
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

chromi   = "chromi"
echo     = (msg) -> console.log msg
ignoreID = "connect heartbeat done info error ?".split /\s+/

# #####################################################################
# Socket response class.

class Respond
  constructor: (sock) -> @sock = sock
  done: (msg, id) -> @send "done",  msg, id
  info: (msg, id) -> @send "info",  msg, id
  error: (msg, id) -> @send "error", msg, id

  send: (type, msg, id) ->
    id = "?" unless id
    if @send
      @sock.send [ chromi, id, "#{type}" ].concat(msg).map(encodeURIComponent).join " "
    else
      echo "#{me}: sending without a socket?"

# #####################################################################
# Handler.

handler = (respond, id, msg) ->
  if msg.length is 0
    # Ping.
    return respond.done [], id
  if msg.length isnt 2
    # Invalid request.
    return respond.error "invalid request:".split(/\s/).concat(msg), id
  [ method, json ] = msg
  if not method
    return respond.error "no method:".split(/\s/).concat(msg), id
  # Locate function.
  prev = func = window
  for term in method.split "."
    prev = func
    func = func?[term] if term
  # Parse JSON/argument.
  if not func
    return respond.error "could not find function".split(/\s/).concat [method], id
  # Parse arguments.
  try
    args = JSON.parse json
  catch error
    return respond.error "JSON parse".split(/\s/).concat [json], id
  # Call function.
  try
    func.apply prev, args.concat [ (stuff...) -> respond.done [ JSON.stringify stuff ], id ]
  catch error
    return respond.error "call".split(/\s/).concat [method, json], id

# #####################################################################
# The web socket.

serverCount = 0

class WebsocketWrapper
  count: 0

  constructor: ->
    echo "#{chromi} starting #{++serverCount}"
    return unless "WebSocket" of window
    return unless @sock = new WebSocket "ws://#{config.host}:#{config.port}/"
    # Initialisation.
    @sock.onopen = =>
      echo "       connected"
      @respond = new Respond @sock
      @respond.info [ "connect" ]
      @interval = setInterval ( => @respond.info [ "heartbeat", ++@count ] ), config.beat
    # Message handling.
    @sock.onmessage = (event) ->
      msg = event.data.split(/\s+/).map decodeURIComponent
      [ signal, id ] = msg
      handler @respond, id, msg.splice(2) if signal == chromi and id and not id in ignoreID
    # Error/close handling.
    @sock.onerror = => @sock.close()
    @sock.onclose = => @close()

  # Clean up and, after a brief interval, attempt to reconnect.
  close: ->
    clearInterval @interval if @interval
    [ "interval", "respond", "sock" ].forEach (f) -> delete @[f]
    setTimeout ( -> new WebsocketWrapper() ), config.beat

# #####################################################################
# Start ...

new WebsocketWrapper()

