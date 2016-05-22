data = require("data")
utils = require("utils")


start_content_edit = (event) ->
  self = $(this)
  target = $(self.data("target"))
  target.attr("contenteditable", "true")
  target.focus()
  length = target.val().length
  range = document.createRange() #Create a range (a range is a like the selection but invisible)
  range.selectNodeContents(target[0]) #Select the entire contents of the element with the range
  range.collapse(false) #collapse the range to the end point. false means collapse to end rather than the start
  selection = window.getSelection() #get the selection object (allows you to change selection)
  selection.removeAllRanges() #remove any selections already made
  selection.addRange(range) #make the range you have just created the visible selection

start_content_new = (event) ->



being_template = require("templates/being")
render_being = (being) ->
  $("#data-view").html(being_template({
    events: being.events,
    name: being.get_name(),
    born: being.get_born(),
    died: being.get_died(),
    description: being.get_description(),
    marital_status: being.get_marital_status(),
    "current_date": data.current_date,
    "date_to_pretty": utils.date_to_pretty,
    "date_until": utils.date_until,
    "date_since": utils.date_since,
    "date_diff": utils.date_diff,
  }))

  #$(".activate_edit").unbind().click(start_content_edit)
  #$(".activate_new").unbind().click(start_content_new)
  new EditableComponent(being, $("#being-name"), false)
  new EditableComponent(being, $("#being-description"), true)

  console.log("Description", being.get_description())


###
  Turns an element into editable
###
class EditableComponent
  constructor: (@being, @element, @multiline) ->
    if !@multiline?
      @multiline = false
    @editing = false
    @element.addClass("editable-component")
    @element.hover(@show_info, @hide_info)
    @element.click({self: @}, @click)
    @element.keypress({self: @}, @keypress)
    @element.attr("contenteditable", true)

  click: (event) ->
    console.log("Click")

  keypress: (event) ->
    self = event.data.self
    console.log("Keypress", event.which, event)
    switch event.which
      when 13
        if !self.multiline or event.shiftKey
          self.save()
          event.preventDefault()
          return false

  save: () ->
    @element.blur()


  show_info: (event) ->
    console.log("Show info")

  hide_info: (event) ->
    console.log("Hide info")

exports.render_being = render_being