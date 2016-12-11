###

###
readline = require 'readline'
path = require 'path'
fs = require 'fs'
_ = require 'lodash'
Promise = require 'bluebird'



class Table
  constructor: ( @headers={}, @rows=[] ) ->
    @raw = []
  @parse_headers: ( line ) ->
    headers = []
    keys = line.split /\s+/
    keys.shift()
    for key in keys
      w = line.match ///#{key}\s*///
      if not w
        throw Error key
      col = key: key, offset: w.index, width: w[0].length, match: w
      headers.push col
      if headers.length == 1
        headers[0].offset -= 2
    headers
  parse_row: ( line ) ->
    row = {}
    lasthd = @headers[@headers.length-1]
    if line.length > lasthd.offset+lasthd.width
      lasthd.width = line.length-lasthd.offset
    for hd in @headers
      row[hd.key] = line.substr( hd.offset, hd.width ).trim()
    @rows.push row
    row
  @parse: ( filename ) ->
    table = new Table null
    new Promise ( resolve, reject ) ->
      lineReader = readline.createInterface(
        input: fs.createReadStream filename
      )
      lineReader.on 'line', (line) ->
        if not line.trim() then return
        comment = line.match /^#(.*)$/
        if comment
          if _.isEmpty table.headers
            table.headers = Table.parse_headers line
          return
        table.raw.push line
      lineReader.on 'close', ->
        for line in table.raw
          table.parse_row line
        resolve table
  find: ( col, value ) ->
    for row in @rows
      if row[col] == value
        return row

module.exports = {}

module.exports.Table = Table

