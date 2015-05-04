
libcomponent = require '../../src/node/component/index'


describe 'DirMeta', ->

  it 'should return local package metafiles', ->

    cwd = process.cwd()
    expect( libcomponent.DirMeta.findDirMeta cwd ).toEqual [
      'package.json'
      'package.yaml'
      'ReadMe.rst'
    ]
  it 'should load local package metafiles', ->

    cwd = process.cwd()
    expect( libcomponent.DirMeta.load cwd ).toNotBe null

