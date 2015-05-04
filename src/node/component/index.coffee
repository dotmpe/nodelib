DirMeta
# Metadata recognition

fs = require 'fs'
path = require 'path'

_ = require 'lodash'
yaml = require 'js-yaml'
minimatch = require 'minimatch'

comp_exports_fn = path.join __dirname, './index.yaml'
comp_exports = yaml.safeLoad fs.readFileSync comp_exports_fn, 'utf8'
#libmetadata = require '../metadata'



meta_file_exts = [
  '.yaml'
  '.json'
  '.ini'
  '.rst'
]
dir_meta_files = [
  #'package{'+meta_file_exts.join(',')+'}'
  'package.*'
  'module.*'
  '{'+meta_file_exts.join(',')+'}'
  'manifest.*'
  'main.*'
  'readme.*'
  'index.*'
]


class DirMeta

  # return all candidate files for dir-bound metadata in from_path
  @findDirMeta: ( from_path ) ->
    meta_candidates = []
    local_files = fs.readdirSync from_path
    for dir_pack_match in dir_meta_files
      for local_file in local_files
        if minimatch( local_file, dir_pack_match, nocase: true )
          if local_file in meta_candidates
            continue
          meta_candidates.push local_file
    meta_candidates

  @getDirMeta: ( from_path ) ->
    candidates = @findDirMeta from_path
    list = []
    for p in candidates
      list.push @loadInstance p
    list

  @load: ( from_path ) ->
    @getDirMeta from_path

  @loadInstance: ( from_path, out={} ) ->
    c = path.parse from_path
    ext = c.ext.substr 1
    if formats.hasOwnProperty ext
      meta_path = path.join c.dir, c.base
      if '*' of formats[ ext ]
        h = formats[ ext ]['*']
      else if c.base of formats[ ext ]
        h = formats[ ext ][ c.base ]
      if out.log?
        out.log 'Loading', meta_path
      h().load meta_path


lazy_include = ( pack ) ->
  ->
    require pack


comps = {}
comp_names = []

for format of comp_exports
  comp_names = _.union( comp_names, ( name for patt, name of comp_exports[ format ] ))

for comp_name in comp_names
  comps[comp_name] = lazy_include './'+comp_name

formats = {}
for format of comp_exports
  for patt, name of comp_exports[ format ]
    comp = comps[ name ]
    if not formats[ format ]?
      formats[ format ] = {}
    formats[ format ][ patt ] = comp


module.exports =

  components: comps 
  formats: formats

  DirMeta: DirMeta


