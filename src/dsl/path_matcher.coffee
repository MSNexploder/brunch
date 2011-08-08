_ = require 'underscore'
path = require 'path'

class exports.PathMatcher
  constructor: (dsl, filePattern) ->
    filePattern = _.flatten [filePattern]

    @dsl = dsl
    @options =
      filePattern: filePattern

  use: (compiler, options = {}) ->
    @name = compiler
    _.extend(@options, options)
    @

  output: (filePath) ->
    @options.output = path.join(@dsl._buildPath, filePath)
