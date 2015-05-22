templates = {
  error_page: require("templates/error_page"),
  login_page: require("templates/login_page"),
  loading_page: require("templates/loading_page")
}


connection = require("connection")


setup = ->

  show_loading()

  console.log("Ready!")
  console.log("YES")
  console.log()
  # Check websockets are available
  if !Modernizr.websockets
    return show_error("Your browser doesn't support websockets!")

  # Establish connection
  connection.connect()

show_loading = ->
  $('body').html(templates.loading_page())

show_error = (reason) ->
  return $('body').html(templates.error_page({reason: reason}))


exports.setup = setup
exports.show_error = show_error
exports.templates = templates
exports.show_loading = show_loading