events = require("events")
data = require("data")
###
  Being such a person, animal etc living being.
###
class Being
  constructor: ({@uid, events}) ->
    if !@uid?
      random_id = Math.random().toString().substr(2)
      while random_id in data.beings
        random_id = Math.random().toString().substr(2)
      @uid = random_id

    if events?
      @events = (events.build_event(event_data) for event_data in events)
    else
      @events = []

  add_event: (event) ->
    @events.push(event)
    @events.sort(events.event_sorter)

  get_name: (date) ->
    for event in @events by -1 when event instanceof events.NameEvent
      return event.name
    return "Unnamed baby"

  get_born: () ->
    for event in @events when event instanceof events.BirthEvent
      return event.date
    return false

  get_died: () ->
    for event in @events
      if event.type != "death"
        continue
      return event.date

    return false

  get_description: () ->
    description = ""
    for event in @events when event.date <= data.current_date and event instanceof events.DescriptionEvent
      description = event.get_description(description)
    return if !description.length then "No description" else description

  # Marriage can end in divorce or death
  get_marital_status: () ->
    status = ["Unmarried", null]
    history = [status]

    for event in @events
      if event.type == "marriage"
        status = ["Married", event]
        history.push(status)

    return [status, history]

  add_title: (place, position=Place.POSITIONS.ruler, date=data.current_date) ->
    aquire_event = events.AcquireTitleEvent(place, position, date)
    current_title_holder = place.get_current_title_holder(position, date)



class Place
  @POSITIONS = {
    ruler: "ruler"
  }

  get_current_title_holder = (position, date=data.current_date) ->
    if position not in Place.POSITIONS
      throw "Undefined place title position!"
    for event in @events
      null
      # TODO wut??
      # Should all events define also who the event is happening to?





exports.Being = Being
exports.Place = Place