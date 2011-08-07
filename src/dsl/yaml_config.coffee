_    = require 'underscore'
yaml = require 'yaml'
fs   = require 'fs'
util = require 'util'
dsl  = require './index'

class exports.YamlConfig
  constructor: (path, options) ->
    @path = path
    @options = options
    @data = yaml.eval fs.readFileSync(path, 'utf8')

  toOptions: ->
    _.defaults(@data, @options.stitch)

    config_string = """
      files([/\\.styl$/]).use('stylus')
      files([/\\.coffee$/, /src\\/.*\\.js$/, new RegExp("#{@data.templateExtension}$")])
        .use('stitch', { minify: #{@data.minify}, dependencies: #{util.inspect @data.dependencies} })
    """

    # workaround for legacy buildPath setting
    options = dsl.run config_string
    options.buildPath = @data.buildPath || @options.buildPath
    options
