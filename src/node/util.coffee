###*
# Formats mongoose errors into proper array
#
# @param {Array} errors
# @return {Array}
# @api public
###

exports.errors = (errors) ->
  keys = Object.keys(errors)
  errs = []
  # if there is no validation error, just display a generic error
  if !keys
    return [ 'Oops! There was an error' ]
  keys.forEach (key) ->
    errs.push errors[key].message
    return
  errs

###*
# Index of object within an array
#
# @param {Array} arr
# @param {Object} obj
# @return {Number}
# @api public
###

exports.indexof = (arr, obj) ->
  index = -1
  # not found initially
  keys = Object.keys(obj)
  # filter the collection with the given criterias
  result = arr.filter((doc, idx) ->
    # keep a counter of matched key/value pairs
    matched = 0
    # loop over criteria
    i = keys.length - 1
    while i >= 0
      if doc[keys[i]] == obj[keys[i]]
        matched++
        # check if all the criterias are matched
        if matched == keys.length
          index = idx
          return idx
      i--
    return
  )
  index

###*
# Find object in an array of objects that matches a condition
#
# @param {Array} arr
# @param {Object} obj
# @param {Function} cb - optional
# @return {Object}
# @api public
###

exports.findByParam = (arr, obj, cb) ->
  index = exports.indexof(arr, obj)
  if ~index and typeof cb == 'function'
    return cb(undefined, arr[index])
  else if ~index and !cb
    return arr[index]
  else if ! ~index and typeof cb == 'function'
    return cb('not found')
  # else undefined is returned
  return
