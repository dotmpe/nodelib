###

Parse specs.rst
  - Check indices, build ids, check refs.

Update one file using another
  - Update descriptions given existing index
  - Create new indices for new descriptions

Print
  - specs.rst
  - specs.refs.rst
  - specs.res.cites.rst
  - specs.yaml

###
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

context = require './context'



class Spec
  constructor: ( @description=null, @specs=[] ) ->
  add: ( spec ) ->
    specs.push spec

  @root: null
  @add: ( spec ) ->
    Spec.root.add spec
  
  @update: ( doc ) ->


class Output
  constructor: ->
   
class YamlOutput extends Output
  constructor: ->
  write: ->



module.exports.parse = ( filename ) ->

  # Root specs
  suites = []
  nstack = ( indent='' ) ->
    indent: indent
    specs: []
    description: null
    index: null
    sid: null
  stack = [ ]

  lineReader = require('readline').createInterface(
    input: fs.createReadStream filename
  )

  lineReader.on 'line', (line) ->
    if not line.trim() then return
    m = line.match /^\s*([0-9\.]+|-)\s([^\[]*)(\s\[([0-9`_\.]+)\])?$/
    if m
      ws = line.match /^(\s*)/
      root = ws[1].length == 0
      if root
        nst = nstack ws[1]
        nst.sid = m[1]
        nst.description = m[2].trim()
        stack.push nst
        suites.push nst

      if stack[stack.length-1].indent.length > ws[1].length
        while stack[stack.length-1].indent.length != ws[1].length
          #console.log 'pop root:', stack[stack.length-1].sid
          stack.pop()
        console.log ''

      if stack[stack.length-1].indent == ws[1]
        if root
          stack[stack.length-1].index = suites.length
          console.log ''
        else
          nst = nstack ws[1]
          nst.index = stack[stack.length-1].index+1
          nst.description = m[2].trim()
          stack.pop()
          if stack[stack.length-1].sid == '-'
            nst.sid = String(nst.index)+"."
          else
            nst.sid = stack[stack.length-1].sid+String(nst.index)+"."
          stack.push nst

        try
          idx = parseInt m[1].trim('.'), 10
        catch err
          null
        if isNaN idx
          idx = '-'

        if typeof(idx) != 'string' and stack[stack.length-1].index != idx
          if idx != 0
            throw Error "Index #{stack[stack.length-1].index} #{m[1]}"

        console.log stack[stack.length-1].indent\
          +stack[stack.length-1].sid, stack[stack.length-1].description

      else if stack[stack.length-1].indent.length < ws[1].length
        nst = nstack ws[1]
        nst.description = m[2].trim()
        try
          nst.index = parseInt m[1].trim('.'), 10
        catch err
          null
        if isNaN nst.index
          nst.index = suites.length
        if stack[stack.length-1].sid == '-'
          nst.sid = String(nst.index)+"."
        else
          nst.sid = stack[stack.length-1].sid+String(nst.index)+"."
        console.log ''
        console.log nst.indent+nst.sid, nst.description
        stack.push nst

    else
      null #console.log 'new:', line


module.exports.print = ( doc ) ->


module.exports.print_refs = ( doc ) ->


module.exports.print_components = ( doc ) ->


