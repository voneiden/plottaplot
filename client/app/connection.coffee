connection = null;
ready = false
plottaplot = require("plottaplot")

on_open = () ->
  ready = true
  plottaplot.show_error("We are connected!")
  console.log("Connected")

on_event = () ->
  console.log("Event")


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






exports.connect = connect
