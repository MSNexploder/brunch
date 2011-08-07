# External dependencies.
parser      = require 'nomnom'
path        = require 'path'
brunch      = require './brunch'
helpers     = require './helpers'
dsl         = require './dsl'
colors      = require('../vendor/termcolors').colors
fs          = require 'fs'
_           = require 'underscore'

# The list of all the valid option flags
globalOpts =
  version:
    abbr: 'v'
    help: 'display brunch version'
    callback: ->
      return version()
  output:
    abbr: 'o'
    help: 'set build path'
    expectsValue: true
    metavar: "DIRECTORY"
  minify:
    abbr: 'm'
    help  : 'minify the app.js output via UglifyJS'

# The help banner which is printed if brunch command-line tool is called with '--help' option.
banner = '''
  http://brunchwithcoffee.com

  Usage: brunch [command] [options]

  Possible commands are:
    new [<path>]    create new brunch project
    build [<path>]  build project
    watch [<path>]  watch brunch directory and rebuild if something changed
         '''

options = {}

# Run 'brunch' by parsing passed options and determining what action to take.
# This also includes checking for a config file. Options in commandline arguments
# overwrite options from the config file. In this case you are able to have
# reasonable defaults and changed only the options you need to change in this particular case.
exports.run = ->
  options = exports.loadDefaultArguments()

  parser.globalOpts globalOpts
  parser.scriptName 'brunch <command> [<path>]'
  parser.printFunc usage

  # create new brunch app and build it after all files were copied
  parser.command('new').callback( (opts) ->
    options = exports.loadOptionsFromArguments opts, options
    brunch.new options, ->
      rootPath = exports.generateRootPath opts[1]
      options = exports.loadOptionsFromArguments opts, options
      options = exports.loadConfigFile rootPath, options
      brunch.build options
  ).help('Create new brunch project')

  parser.command('build').callback( (opts) ->
    rootPath = exports.generateRootPath opts[1]
    options = exports.loadOptionsFromArguments opts, options
    options = exports.loadConfigFile rootPath, options
    brunch.build options
  ).help('Build a brunch project')

  parser.command('watch').callback( (opts) ->
    rootPath = exports.generateRootPath opts[1]
    options = exports.loadOptionsFromArguments opts, options
    options = exports.loadConfigFile rootPath, options
    brunch.watch options
  ).help('Watch brunch directory and rebuild if something changed')

  parser.parseArgs()

exports.generateRootPath = (appPath) ->
  if appPath? then appPath else 'brunch/' # shouldn't we use the current dir as default root path?

# Load default options
exports.loadDefaultArguments = ->
  # buildPath is created in loadOptionsFromArguments
  stitch =
    templateExtension: 'eco'
    dependencies: []
    minify: false

  options =
    stitch: stitch
    rootPath: 'brunch'

  options

# Load options from config file
exports.loadConfigFile = (rootPath, options) ->
  coffee_config = path.join(rootPath, 'config.coffee')
  yaml_config = path.join(rootPath, 'config.yaml')
  if path.existsSync coffee_config
    dsl.loadConfigFile coffee_config, options
  else if path.existsSync yaml_config
    dsl.loadYamlConfigFile yaml_config, options
  else
    helpers.log colors.lred("brunch:   Couldn't find config.yaml file\n", true)
    process.exit 0

# Load options from arguments
exports.loadOptionsFromArguments = (opts, options) ->
  options.stitch ?= {}
  options.stitch.templateExtension = opts.templateExtension if opts.templateExtension?
  options.stitch.minify = opts.minify if opts.minify?
  options.rootPath = opts[1] if opts[1]?
  if opts.output?
    options.buildPath = opts.output
  else unless options.buildPath?
    options.buildPath = path.join options.rootPath, 'build'
  options

# Print the '--help' usage message and exit.
usage = ->
  process.stdout.write banner
  process.stdout.write helpers.optionsInfo(globalOpts)
  process.exit 0

# Print the '--version' message and exit.
version = ->
  process.stdout.write "brunch version #{brunch.VERSION}\n"
  process.exit 0
