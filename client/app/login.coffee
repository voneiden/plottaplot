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
    $('#password').focus()
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
  console.log("Submit")
  user = $("#user").val()

  if !user? or user.length == 0
    show_login("Invalid username")
    return

  if !static_salt
    plottaplot.show_loading()
    pass = $("#pass").val()

    connection.send({'request': 'static_salt'}, login_submit)




register_submit = ->
  console.log("Register")
  static_salt = false


exports.show_login = show_login