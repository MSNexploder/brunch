fs      = require 'fs'
path    = require 'path'
helpers = require '../helpers'
colors  = require('../../vendor/termcolors').colors
_       = require 'underscore'

options  = require('../brunch').options
Compiler = require('./index').Compiler

class exports.StitchCompiler extends Compiler
  filePattern: ->
    [/\.coffee$/, /src\/.*\.js$/, new RegExp("#{options.templateExtension}$")]

  compile: (files) ->
    stitch = require 'stitch' # lazy load dependencies

    # update package dependencies in case a dependency was added or removed
    this.package().dependencies = this.collectDependencies() if _.any(files, (file) -> file.match(/src\/vendor\//))

    this.package().compile( (err, source) =>
      if err?
        helpers.log "brunch:   #{colors.lred('There was a problem during compilation.', true)}\n"
        helpers.log "#{colors.lgray(err, true)}\n"
      else
        fs.writeFile(path.join(options.buildPath, 'web/js/app.js'), source, (err) =>
          if err?
            helpers.log "brunch:   #{colors.lred('Couldn\'t write compiled file.', true)}\n"
            helpers.log "#{colors.lgray(err, true)}\n"
          else
            helpers.log "stitch:   #{colors.green('compiled', true)} application\n"
        )
    )

  package: ->
    @_package ||= stitch.createPackage (
      dependencies: this.collectDependencies()
      paths: [path.join(options.brunchPath, 'src/app/')]
    )

  # generate list of dependencies and preserve order of brunch libaries
  # like defined in options.dependencies
  collectDependencies: ->
    filenames = fs.readdirSync this.vendorPath()
    filenames = helpers.filterFiles filenames, this.vendorPath()

    args = options.dependencies.slice()
    args.unshift filenames
    additionalLibaries = _.without.apply @, args
    dependencies = options.dependencies.concat additionalLibaries
    _.map dependencies, (filename) => path.join(this.vendorPath(), filename)

  vendorPath: ->
    @_vendor_path ||= path.join(options.brunchPath, 'src/vendor')
