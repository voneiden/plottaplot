###
  Sometimes you gotta do it yourself
###
plottaplot = require("plottaplot")


b1 =
  name: "Sir John",
  id: 1,
  home: "Salisbury",

b2 =
  name: "Sir Make",
  id: 2,
  home: "Salisbury",

b3 =
  name: "Sir John",
  id: 3,
  home: "London"

objects =
  beings: [b1, b2, b3]



reload = ->
  # Setup autocomplete on a new element
  null


show = (query) ->
  null


being_sorter = (a, b) ->
  return (a.name + a.home if a.home?) > (b.name + b.home if b.home?)

beings = (query, callback) ->
  regex = new RegExp(query)
  results = []
  for being in objects.beings
    if regex.test(being.name)
      results.push(being)

    else if being.home? and regex.test(being.home)
      results.push(being)

  results.sort(being_sorter)
  callback(results)

places = (query, callback) ->
  callback([])

events = (query, callback) ->
  callback([])




exports.beings = beings
exports.places = places
exports.events = events