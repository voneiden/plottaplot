data = require("data")
models = require("models")
utils = require("utils")




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
  BirthEvent defines the genealogy and age of the being. Beings should have only one BirthEvent
  unless reincarnation is considered. In that case there should still be a DeathEvent to separate the BirthEvents.

  @param who [models.Being] The being who was born
  @param father [models.Being] The biological father
  @param mother [models.Being] The biological mother
  @param place [models.Place] The place where the birth occurred
  @param date [Date] The date when the birth occurred
###

class BirthEvent
  constructor: ({@who, @father, @mother, @place, @date}) ->

  get_summary: () ->
    return "#{utils.date_to_pretty(@date)}, born."



###
  DeathEvent ends the life of a being.

  @param who [models.Being] The being who died
  @param place [models.Place] The place where the death occurred
  @param date [Date] The date when the death occurred
###
class DeathEvent
  constructor: ({@who, @place, @date}) ->

  get_summary: () ->
    return "#{utils.date_to_pretty(@date)}, died."


###
  Description event - description is stored as a diff patch based on previous description to
  allow altering entries in the history.

  @param what [Object] What is thing being described (Being/Place object)
  @param new_description [String] New description of the thing
  @param old_description [String] Old description of the thing to compare against
  @param date [Date] Date of the description
###
patchtool = new diff_match_patch()
class DescriptionEvent
  constructor: ({what, new_description, old_description, @date}) ->
    console.log("New",new_description,old_description)
    if new_description?
      if !old_description?
        old_description = ""

      @description = patchtool.patch_make(old_description, new_description)
      console.log("Set description to", @description)
    else
      console.log("error")

  #toJSON: () ->
  #  return {date: @date, type: @type, description: patchtool.patch_toText(@description)}

  get_description: (old_text) ->
    if !old_text?
      old_text = ""
    console.log("desc", @description)
    return patchtool.patch_apply(@description, old_text)[0]

  get_summary: () ->
    return false

###
  Name a being or a place

  @param what [Object] What thing is being named (Being/Place object)
  @param name [String] Name of the thing
  @param date [Date] Date when the naming occurred
###
class NameEvent
  constructor: ({@what, @name, @date}) ->

  get_summary: () ->
    return false


###
  Marriage between two beings

  @param pair [Array<models.Being>] The two beings to be wed
  @param date [Date] Date when the marriage occurred
###
class MarriageEvent
  constructor: ({@pair, @date}) ->
    if @pair not instanceof Array or @pair.length != 2
      throw "Bad argument @pair for MarriageEvent: Should consist of two beings"

  get_summary: () ->
    return false

###
  Divorce between two beings

  @param pair [Array<models.Being>] The two beings to be divorced
  @param date [Date] Date when the divorce occurred
###
class DivorceEvent
  constructor: ({@pair, @date}) ->
    if @pair not instanceof Array or @pair.length != 2
      throw "Bad argument @pair for DivorceEvent: Should consist of two beings"


###
  Betrothal between two beings

  @param pair [Array<models.Being>] The two beings to become betrothed to each other
  @param date [Date] Date when the betrothal occurred
###
class BetrothalEvent
  constructor: ({@pair, @date}) ->
    if @pair not instanceof Array or @pair.length != 2
      throw "Bad argument @pair for BetrothalEvent: Should consist of two beings"

###
  Breach of betrothal between two beings

  @param pair [Array<models.Being>] The two beings to breach apart
  @param date [Date] Date when the breach occurred
###
class BreachEvent
  constructor: ({@pair, @date}) ->
    if @pair not instanceof Array or @pair.length != 2
      throw "Bad argument @pair for BreachEvent: Should consist of two beings"

class AcquireTitleEvent
  constructor: ({@place, @position, @date}) ->
    null
    # TODO
    # Determine if place currently has someone with that title
    # Dethrone them
    # TODO don't do this in the constructor!
    # =models.Place.POSITIONS.ruler
class LoseTitleEvent
  constructor: ({@place, @date}) ->


event_types =
  birth: BirthEvent
  death: DeathEvent
  name: NameEvent
  description: DescriptionEvent
  marriage: MarriageEvent
  divorce: DivorceEvent


exports.BirthEvent = BirthEvent
exports.DeathEvent = DeathEvent
exports.NameEvent = NameEvent
exports.DescriptionEvent = DescriptionEvent
exports.MarriageEvent = MarriageEvent
exports.DivorceEvent = DivorceEvent
exports.build_event = build_event
exports.event_sorter = event_sorter
exports.event_types = event_types