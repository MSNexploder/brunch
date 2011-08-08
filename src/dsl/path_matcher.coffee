_ = require 'underscore'
path = require 'path'

class exports.PathMatcher
  constructor: (filePattern) ->
    filePattern = _.flatten [filePattern]

    @options =
      filePattern: filePattern

  use: (compiler, options = {}) ->
    @name = compiler
    _.extend(@options, options)
    @

  output: (filePath) ->
    @options.output = filePath
