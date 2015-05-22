templates = {
  error_page: require("templates/error_page")
}


connection = require("connection")


setup = ->
  console.log("Ready!")
  console.log("YES")
  console.log()
  # Check websockets are available
  if !Modernizr.websockets
    return show_error("Your browser doesn't support websockets!")

  # Establish connection
  connection.connect()


show_error = (reason) ->
  return $('body').html(templates.error_page({reason: reason}))


exports.setup = setup
exports.show_error = show_error

