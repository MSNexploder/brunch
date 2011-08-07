_ = require 'underscore'

class exports.PathMatcher
  constructor: (paths) ->
    paths = if _.isArray(paths) then paths else [paths]

    @options =
      paths: paths

  use: (compiler, options = {}) ->
    @name = compiler
    @

  output: (path) ->
    @options.output = path
