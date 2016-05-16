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
    name = "Unnamed baby"
    for event in @events
      if event.type != "name"
        continue
      else
        name = event.name
    return name

  get_born: () ->
    for event in @events
      if event.type != "birth"
        continue
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
    for event in @events
      if event.date > data.current_date
        break
      if event.type != "description"
        continue
      description = event.get_description(description)
    return description

  # Marriage can end in divorce or death
  get_marital_status: () ->
    status = ["Unmarried", null]
    history = [status]

    for event in @events
      if event.type == "marriage"
        status = ["Married", event]
        history.push(status)

    return [status, history]




exports.Being = Being