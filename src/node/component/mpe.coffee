path = require 'path'

libmetadata = require '../metadata'



class MPE extends libmetadata.types.YAMLGeneric

  @load: ( from_path ) ->
    super from_path


module.exports = MPE

