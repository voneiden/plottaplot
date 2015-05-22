connection = null;
ready = false
plottaplot = require("plottaplot")
login = require("login")
callbacks = []

on_open = () ->
  ready = true
  login.show_login()
  console.log("Connected")

on_event = (event) ->
  console.log("Event", event)
  if callbacks.length > 0
    callback = callbacks.shift()
    console.log("callback", callback)
    callback(JSON.parse(event.data))


on_close = (event) ->

  if event.code != 1000
    if !ready
      plottaplot.show_error("Blimey! Server is unreachable. Try again later.")
      connection.close()
    else
      plottaplot.show_error("Blimey! Connection was lost, attempting to reconnect..")

  else
    plottaplot.show_error("Connection closed. Farewell!")




connect = ->
  connection = new WebSocket("ws://127.0.0.1:9000")
  connection.onmessage = on_event
  connection.onopen = on_open
  connection.onclose = on_close

send = (data, callback) ->
  console.log("Connection", connection)
  connection.send(JSON.stringify(data))
  callbacks.push(callback)





exports.connect = connect
exports.send = send