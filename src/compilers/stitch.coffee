fs        = require 'fs'
path      = require 'path'
helpers   = require '../helpers'
colors    = require('../../vendor/termcolors').colors
stitch    = require 'stitch'
uglify    = require 'uglify-js'
_         = require 'underscore'
brunch    = require '../brunch'

Compiler = require('./base').Compiler

class exports.StitchCompiler extends Compiler

  constructor: (options) ->
    super options
    @vendorPath = 'src/vendor/'

  compile: (files) ->
    # update package dependencies in case a dependency was added or removed
    @package().dependencies = @collectDependencies() if _.any(files, (file) -> file.match(/src\/vendor\//))

    @package().compile( (err, source) =>
      if err?
        helpers.log "brunch:   #{colors.lred('There was a problem during compilation.', true)}\n"
        helpers.log "#{colors.lgray(err, true)}\n"
      else
        helpers.log "stitch:   #{colors.green('compiled', true)} application\n"
        source = @minify source if @options.minify
        @writeToFile @options.output, source
    )

  package: ->
    @_package ?= stitch.createPackage (
      dependencies: @collectDependencies()
      paths: [@generatePath('src/app/')]
    )

  # generate list of dependencies and preserve order of brunch libaries
  # like defined in options.dependencies
  collectDependencies: ->
    filenames = fs.readdirSync @generatePath(@vendorPath)
    filenames = helpers.filterFiles filenames, @generatePath(@vendorPath)

    args = @options.dependencies.slice()
    args.unshift filenames
    additionalLibaries = _.without.apply @, args
    dependencies = @options.dependencies.concat additionalLibaries
    _.map dependencies, (filename) => @generatePath path.join(@vendorPath, filename)

  minify: (source) ->
      helpers.log "uglify:   #{colors.green('minified', true)} application\n"
      abstractSyntaxTree = uglify.parser.parse source
      abstractSyntaxTree = uglify.uglify.ast_mangle abstractSyntaxTree
      abstractSyntaxTree = uglify.uglify.ast_squeeze abstractSyntaxTree
      source = uglify.uglify.gen_code abstractSyntaxTree
