os = require 'os'

_ = require 'lodash'


class LineReader
  constructor: ( @str, @eol = os.EOL, @lines = [] ) ->
  hasNext: ->
    return ! _.isEmpty @str
  next: ->
    line
    p = @str.indexOf @eol
    if p > -1
      line = @str.substr 0, p
      @str = @str.substr p + @eol.length
    else
      line = @str
      @str = ''
    @lines.push line
    return line

isLineComment = ( line ) ->
  line.trim().substr(0, 1) == '#'

cleanLineComment = ( line ) ->
  line.trim().substr(1).trim()

firstComment = ( str ) ->
  lines = []
  lineReader = new LineReader str
  while lineReader.hasNext()
    line = lineReader.next()
    if isLineComment line
      lines.push cleanLineComment line
  lines

module.exports =
  firstComment: firstComment
  isLineComment: isLineComment
  cleanLineComment: cleanLineComment
