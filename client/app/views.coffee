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

  $(".activate_edit").unbind().click(start_content_edit)
  $(".activate_new").unbind().click(start_content_new)

  console.log("Description", being.get_description())

exports.render_being = render_being