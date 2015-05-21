connection = null;
plottaplot = require("plottaplot")

onclose = (reason, details) ->
  console.log("closed", reason, details)
  if reason == "unreachable"
    plottaplot.show_error("Blimey! Server is unreachable. Try again later.")
    connection.close()
  else if reason == "lost"
    plottaplot.show_error("Blimey! Connection was lost, attempting to reconnect..")

  else if reason == "closed"
    plottaplot.show_error("Good bye!")


connect = ->
  connection = new autobahn.Connection({
      url: 'ws://127.0.0.1:9000/ws',
      realm: 'plottaplot'}
  )

  connection.onclose = onclose

  connection.open()

exports.connect = connect
