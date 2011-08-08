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
exports.new = (options, callback) ->
  exports.options = options

  templatePath = path.join(module.id, "/../../template/base")

  path.exists exports.options.rootPath, (exists) ->
    if exists
      helpers.log colors.lred("brunch:   directory already exists - can't create a project in there\n", true)
      process.exit 0

    fileUtil.mkdirsSync exports.options.rootPath, 0755

    helpers.recursiveCopy templatePath, exports.options.rootPath, ->
      exports.createExampleIndex path.join(exports.options.rootPath, 'index.html'), exports.options.buildPath
      callback()
      helpers.log "brunch:   #{colors.green('created ', true)} brunch directory layout\n"

# file watcher
exports.watch = (options) ->
  exports.options = options
  exports.initializeCompilers()

  # let's watch
  helpers.watchDirectory(path: path.join(exports.options.rootPath, 'src'), callOnAdd: true, (file) ->
    exports.dispatch(file)
  )

# building all files
exports.build = (options) ->
  exports.options = options
  exports.initializeCompilers()

  for compiler in compilers
    compiler.compile(['.'])

# creates an example index.html for brunch with the correct relative path to the build directory
exports.createExampleIndex = (filePath, buildPath) ->

  # fixing relativ path
  rootPath = path.join exports.options.rootPath, '/'
  if buildPath.indexOf(rootPath) == 0
    relativePath = buildPath.substr rootPath.length
  else
    relativePath = path.join '..', buildPath

  index = "<!doctype html>\n
<html lang=\"en\">\n
<head>\n
  <meta charset=\"utf-8\">\n
  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">\n
  <link rel=\"stylesheet\" href=\"#{ path.join(relativePath, 'web/css/main.css') }\" type=\"text/css\" media=\"screen\">\n
  <script src=\"#{ path.join(relativePath, 'web/js/app.js') }\"></script>\n
  <script>require('main');</script>\n
</head>\n
<body>\n
</body>\n
</html>"
  fs.writeFileSync(filePath, index)

# initializes all used compilers
exports.initializeCompilers = ->
  compilers = for name, options of exports.options
    # fix for legacy options
    continue if _.include ['buildPath', 'rootPath'], name
    compiler = require('./compilers')[["#{helpers.capitalize name}Compiler"]]
    new compiler(exports.options)

# dispatcher for file watching which determines which action needs to be done
# according to the file that was changed/created/removed
exports.dispatch = (file) ->
  for compiler in compilers
    if compiler.matchesFile(file)
      compiler.fileChanged(file)
      break
