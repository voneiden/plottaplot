plottaplot = require('plottaplot')
autocomplete = require('autocomplete')
data = require('data')
utils = require("utils")
views = require("views")

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


  #$('body').html(plottaplot.templates.main(context))
  $('body').html(plottaplot.templates.main_view(context))
  #autocomplete.reload()

  $("#map-view-slider").click(slide_map)


  $("#date-view-input").change(date_change).trigger("change")
  setup_typeahead()




slide_map = () ->
  map_view = $("#map-view")
  console.log(map_view.css("flex-grow"))
  if (map_view.css("flex-grow") == "0")
    map_view.css("flex-grow", "1")
  else
    map_view.css("flex-grow", "0")

date_change = () ->
  self = $(this)
  data.current_date = new Date(self.val())
  data.current_moment = moment(data.current_date)
  console.log("Date changed to", data.current_date)
  views.render_being(John)


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










models = require("models")
events = require("events")

John = new models.Being({})
birth_of_John = new events.BirthEvent({who: John, date: new Date("0485-12-11"), father: null, mother: null, place: null})
name_of_John = new events.NameEvent({what: John, date: new Date("0485-12-25"), name: "John Johnson"})
description_of_John = new events.DescriptionEvent({what: John, date: new Date("0485-12-11"), new_description: "John was born, pale as snow", old_description: ""})
description_of_John2 = new events.DescriptionEvent({what: John, date: new Date("0490-12-11"), new_description: "John was born in December, pale as snow. He seemed to grow as a strong young lad.", old_description: "John was born, pale as snow"})
death_of_John = new events.DeathEvent({who: John, date: new Date("0560-10-10"), place: null})



John.add_event(birth_of_John)
John.add_event(death_of_John)
John.add_event(description_of_John)
John.add_event(description_of_John2)
John.add_event(name_of_John)


Jane = new models.Being({})
birth_of_Jane = new events.BirthEvent({who: Jane, date: new Date("0486-12-11"), father: null, mother: null, place: null})
name_of_Jane = new events.NameEvent({what: Jane, date:new Date( "0487-01-25"), name: "Jane"})
marriage_of_Jane_and_John = new events.MarriageEvent({pair: [John, Jane], date: new Date("0505-03-15")})
#marriage_of_Jane = new events.MarriageEvent({date: new Date("0505-03-15"), with_being: John})
#marriage_of_John = new events.MarriageEvent({date:new Date( "0505-03-15"), with_being: Jane})
Jane.add_event(birth_of_Jane)
Jane.add_event(marriage_of_Jane_and_John)
Jane.add_event(name_of_Jane)
John.add_event(marriage_of_Jane_and_John)



console.log(data)

# TODO automate this
data.beings[John.uid] = John
data.beings[Jane.uid] = Jane

serialijse.declarePersistable(models.Being)
serialijse.declarePersistable(diff_match_patch.patch_obj)

for event_name, event_class of events.event_types
  console.log(event_class)
  serialijse.declarePersistable(event_class)
###
serialijse.declarePersistable(events.DeathEvent)
serialijse.declarePersistable(events.NameEvent)
serialijse.declarePersistable(events.MarriageEvent)
serialijse.declarePersistable(events.DescriptionEvent)
###

d=serialijse.serialize(data)
console.log("Serialized:", d, d.length)


scall = (error, data) ->
  d2 = new TextDecoder().decode(data)
  console.log("Zser",error,d2,d2.length)
serialijse.serializeZ(data, scall)


#console.log(JSON.stringify(data))

# Setup typeahead
autocomplete = require("autocomplete")
setup_typeahead = () ->
  ###
  bloodhound_beings = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: autocomplete.beings
  });
  ###
  console.log(autocomplete.beings)

  autocomplete_template = require("templates/main/autocomplete")
  typeahead_element = $('#typeahead-search');
  typeahead_element.typeahead({
              hint: true,
              highlight: true,
              minLength: 1
          },
          {
              name: 'Beings',
              source: autocomplete.beings,
              display: "name",
              templates: {
                  header: '<h3 class="league-name">Beings</h3>',
                  suggestion: autocomplete_template
              }
          },
          {
              name: 'Places',
              source: autocomplete.places,
              templates: {
                  header: '<h3 class="league-name">Places</h3>'
              }
          },
          {
              name: 'Events',
              source: autocomplete.events,
              templates: {
                  header: '<h3 class="league-name">Events</h3>'
              }
          });
  console.log("Typeahead enabled", typeahead);


  typeahead_element.bind("typeahead:select", (e,x) ->  console.log("Select", e, x))
  typeahead_element.bind("typeahead:autocomplete", (e,x) ->  console.log("Select", e, x))

  test = (e,x) ->
    console.log("Keypress", e, x)
  console.log("Element", typeahead_element.length);
  typeahead_element.keypress(test)


exports.show = show
exports.typeahead_select = typeahead_select
exports.typeahead_autocomplete = typeahead_autocomplete
exports.keypress = keypress

