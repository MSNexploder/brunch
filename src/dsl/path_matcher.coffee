_ = require 'underscore'
path = require 'path'

class exports.PathMatcher
  constructor: (rootPath, filePattern) ->
    filePattern = _.flatten [filePattern]

    @rootPath = rootPath
    @options =
      filePattern: filePattern

  use: (compiler, options = {}) ->
    @name = compiler
    _.extend(@options, options)
    @

  output: (file) ->
    @options.output = path.resolve(@rootPath, file)
