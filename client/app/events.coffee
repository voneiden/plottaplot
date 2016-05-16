data = require("data")
models = require("models")
utils = require("utils")

event_types =
  birth: BirthEvent
  death: DeathEvent
  description: DescriptionEvent


build_event = (event) ->
  return new event_types[event.type](event)

event_sorter = (a, b) ->
  if a.date > b.date
    return 1
  #else if a.date < b.date
  #  return -1

  else
    return -1

###
  Every being should have a birth event. It defines when the being
  was born and basic genealogy.
###
class BirthEvent
  constructor: ({date, @father, @mother, @place}) ->
    @date = new Date(date)
    @type = "birth"

  get_summary: () ->
    return "#{utils.date_to_pretty(@date)}, born."

###
  Death event determines when (and where) the being has died
###
class DeathEvent
  constructor: ({date, @place}) ->
    @date = new Date(date)
    @type = "death"

  get_summary: () ->
    return "#{utils.date_to_pretty(@date)}, died."


###
  Description event - description is stored as a diff patch based on previous description to
  allow non-linear editing (can you even say like that?).
###
patchtool = new diff_match_patch()
class DescriptionEvent
  constructor: ({date, description, diff_from}) ->
    @date = new Date(date)
    @type = "description"

    if diff_from?
      @description = patchtool.patch_make(diff_from, description)
    else
      @description = patchtool.patch_fromText(description)

  toJSON: () ->
    return {date: @date, type: @type, description: patchtool.patch_toText(@description)}

  get_description: (from) ->
    return patchtool.patch_apply(@description, from)[0]

  get_summary: () ->
    return false

###
  The being was named. A Being's name can change multiple times during their lifetimes depending on titles.
###
class NameEvent
  constructor: ({date, @name}) ->
    @date = new Date(date)
    @type = "name"

  get_summary: () ->
    return false

class MarriageEvent
  constructor: ({date, with_being}) ->
    @date = new Date(date)
    @type = "marriage"
    if Number.isInteger(with_being)
      if with_being in data.beings
        @with_being = data.beings[with_being]
      else
        throw "Unresolvable with_being for #{with_being}"
    else if with_being instanceof models.Being
      @with_being = with_being
    else
      throw "Invalid type with_being: #{with_being}"

  get_summary: () ->
    return false


  toJSON: () ->
    uid = @with_being
    if @with_being instanceof models.Being
      uid = @with_being.uid
    return {date: @date, with_being: uid}


exports.BirthEvent = BirthEvent
exports.DeathEvent = DeathEvent
exports.NameEvent = NameEvent
exports.DescriptionEvent = DescriptionEvent
exports.MarriageEvent = MarriageEvent
exports.build_event = build_event
exports.event_sorter = event_sorter