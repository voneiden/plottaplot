plottaplot = require('plottaplot')
autocomplete = require('autocomplete')

templates = {}
templates.noselect = require('templates/main/noselect')
typeahead = null
active = null

show = ->
  # Generate bottom stuff
  context =
    autocomplete: plottaplot.templates.autocomplete()

  if !active?
    context.stuff = templates.noselect()
  else if active.length == 2
    if active[1] == null
      context.stuff = "choose new object type"
    else
      context.stuff = "show object"

  else
    context.stuff = "Error, unknown context"


  $('body').html(plottaplot.templates.main(context))
  #autocomplete.reload()



activate = (name, type) ->
  # Attempt to determine type
  if !type?
    plottaplot.data.being[name]

  else if type == "being"
    null
  else if type == "place"
    null
  else if type == "event"
    null
  else
    console.log("Error type") # TODO


  console.log(name, type)


typeahead_select = (event, value) ->
  console.log(event, value)

typeahead_autocomplete = (event, value) ->
  console.log(event, value)


keypress = (event) ->
  if event.keyCode == 13
    activate($(".tt-input").val());
    typeahead.typeahead('val', '')

  console.log(event)

exports.show = show
exports.typeahead_select = typeahead_select
exports.typeahead_autocomplete = typeahead_autocomplete
exports.keypress = keypress

