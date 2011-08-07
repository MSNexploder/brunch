_ = require 'underscore'

class exports.PathMatcher
  constructor: (filePattern) ->
    filePattern = if _.isArray(filePattern) then filePattern else [filePattern]

    @options =
      filePattern: filePattern

  use: (compiler, options = {}) ->
    @name = compiler
    _.extend(@options, options)
    @

  output: (path) ->
    @options.output = path
