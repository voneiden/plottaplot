data = require("data")

date_to_pretty = (date) ->
  if !date
    return "Unknown"
  else
    return moment(date).format("MMMM Do, Y")

date_until = (date) ->
  if !date
    return "?"
  else
    return data.current_moment.to(date)

date_since = (date, since) ->
  if !date
    return "?"
  else if since?
    return moment(since).from(date)
  else
    return data.current_moment.from(date)

date_diff = (date1, date2) ->
  if !date1
    return "?"
  if date2?
    return moment(date2).from(date1, true)
  else
    return data.current_moment.from(date1, true)

exports.date_to_pretty = date_to_pretty
exports.date_until = date_until
exports.date_since = date_since
exports.date_diff = date_diff