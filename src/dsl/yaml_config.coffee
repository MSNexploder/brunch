_    = require 'underscore'
yaml = require 'yaml'
fs   = require 'fs'
path = require 'path'
util = require 'util'
dsl  = require './index'

class exports.YamlConfig
  constructor: (path, options) ->
    @path = path
    @options = options
    @data = yaml.eval fs.readFileSync(path, 'utf8')

  toOptions: ->
    _.defaults(@data, @options.stitch)
    @data.buildPath ?= @options.buildPath
    @data.buildPath ?= 'build'
    @data.rootPath = @options.rootPath

    config_string = """
      files([/\\.styl$/]).use('stylus').output('#{path.join(@data.buildPath, 'web/css/main.css')}')
      files([/\\.coffee$/, /src\\/.*\\.js$/, new RegExp("#{@data.templateExtension}$")])
        .use('stitch', { minify: #{@data.minify}, dependencies: #{util.inspect @data.dependencies} })
        .output('#{path.join(@data.buildPath, 'web/js/app.js')}')
    """

    # workaround for legacy buildPath setting
    options = dsl.run config_string
    options.buildPath = @data.buildPath
    options.rootPath = @data.rootPath
    options
