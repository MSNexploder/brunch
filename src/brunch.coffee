# brunch can be used via command-line tool or manually by calling run(options).

# External dependencies.
_         = require 'underscore'
fs        = require 'fs'
path      = require 'path'
helpers   = require './helpers'
fileUtil  = require 'file'
colors    = require('../vendor/termcolors').colors

# the current brunch version number
exports.VERSION = require('./package').version

# base directory of the current project
exports.ROOT_PATH = '.'

# available compilers
compilers = []

# project skeleton generator
exports.new = (root_path, callback) ->
  template_path = path.join(module.id, "/../../template/base")

  path.exists root_path, (exists) ->
    if exists
      helpers.log colors.lred("brunch:   directory already exists - can't create a project in there\n", true)
      process.exit 0

    fileUtil.mkdirsSync root_path, 0755

    helpers.recursiveCopy template_path, root_path, ->
      exports.createExampleIndex path.join(root_path, 'index.html'), callback
      helpers.log "brunch:   #{colors.green('created ', true)} brunch directory layout\n"

# file watcher
exports.watch = (root_path, options) ->
  process.chdir root_path
  exports.initializeCompilers options 

  # let's watch
  helpers.watchDirectory(path: 'src', callOnAdd: true, (file) ->
    exports.dispatch(file)
  )

# building all files
exports.build = (root_path, options) ->
  process.chdir root_path
  exports.initializeCompilers options

  for compiler in compilers
    compiler.compile(['.'])

# creates an example index.html for brunch with the correct relative path to the build directory
exports.createExampleIndex = (filePath, callback) ->
  index = """
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
      <link rel="stylesheet" href="build/web/css/main.css" type="text/css" media="screen">
      <script src="build/web/js/app.js"></script>
      <script>require('main');</script>
    </head>
    <body>
    </body>
    </html>
  """
  fs.writeFile(filePath, index, callback)

# initializes all used compilers
exports.initializeCompilers = (options) ->
  compilers = for name, settings of options
    # fix for legacy options
    continue if _.include ['buildPath', 'rootPath'], name
    compiler = require('./compilers')[["#{helpers.capitalize name}Compiler"]]
    new compiler(settings)

# dispatcher for file watching which determines which action needs to be done
# according to the file that was changed/created/removed
exports.dispatch = (file) ->
  for compiler in compilers
    compiler.fileChanged(file) if compiler.matchesFile(file)
