plottaplot = require("plottaplot")
connection = require("connection")

user = false
pass = false

static_salt = false
dynamic_salt = false

show_login = (error) ->
  $('body').html(plottaplot.templates.login_page({'error': error}))

  user = $.jStorage.get("user")
  if user
    $('#user').val(user)
    $('#pass').focus()
  else
    $('#user').focus()

  $('#container').keypress((e) -> login_submit() if e.which == 13)
  $('#login').click(login_submit)
  $('#register').click(register_submit)

  static_salt = false
  dynamic_salt = false
  user = $('#user').val()
  pass = $('#pass').val()




login_submit = (data) ->
  console.log("login_submit..")
  console.log("Submit data", data)
  console.log("static salt is set to", static_salt)
  console.log("user is set to", user)

  if data?
    if data.static_salt?
      console.log("got dyn")
      static_salt = data.static_salt

    if data.dynamic_salt?
      dynamic_salt = data.dynamic_salt

    if data.result == false
      show_login("Something went wrong (#{if data.reason? then data.reason  else "unknown reason"})")
      return

  # Request static salt
  if !static_salt or !dynamic_salt
    console.log("login_submit: Requesting static salt")
    user = $('#user').val()
    pass = $('#pass').val()
    if !user? or user.length == 0
      show_login("Invalid username")
      return
    plottaplot.show_loading()
    connection.send({'request': 'login_salts', 'user': user}, login_submit)

  else
    console.log("login_submit: Requesting login")
    connection.send({'request': 'login', 'user': user, 'pass': sha256(sha256(pass + static_salt) + dynamic_salt)}, login_submit)


register_submit = (data) ->
  console.log("register_submit..")
  if data?
    if data.static_salt?
      static_salt = data.static_salt

    if data.dynamic_salt?
      dynamic_salt = data.dynamic_salt

  if !static_salt or !dynamic_salt
    console.log("register_submit: Requesting static salt")
    user = $('#user').val()
    pass = $('#pass').val()
    if !user? or user.length == 0 or !pass? or pass.length == 0
      show_login("Username or password cannot be empty.")
      return
    plottaplot.show_loading()
    connection.send({'request': 'login_salts', 'user': user}, register_submit)

  else
    console.log("register_submit: Requesting register")
    connection.send({'request': 'register', 'user': user, 'pass': sha256(pass + static_salt)}, login_submit)

exports.show_login = show_login