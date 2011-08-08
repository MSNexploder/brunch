fs = require 'fs'
coffee = require 'coffee-script'
path = require 'path'
scoped = require('../helpers').scoped
PathMatcher = require('./path_matcher').PathMatcher
YamlConfig = require('./yaml_config').YamlConfig

class DSL
  constructor: ->
    @matchers = []
    @context = {}
    @locals = {
      files: => @files.apply this, arguments
      require: require
      global: global
      process: process
      module: module
    }

  files: (paths...) ->
    matcher = new PathMatcher(paths)
    @matchers.push matcher
    matcher

  defineWith: (code) ->
    scoped(code)(@context, @locals)

  readAndCompile: (file) ->
    code = @read file
    coffee.compile code

  read: (file) -> fs.readFileSync file, 'utf8'

  runFile: (file) ->
    @locals.__filename = path.join(process.cwd(), file)
    @locals.__dirname = process.cwd()
    @locals.module.filename = @locals.__filename
    code = @readAndCompile file
    @run code

  run: (code) ->
    @defineWith code

    options = {}
    for matcher in @matchers
      next unless matcher.name?

      options[matcher.name] = matcher.options

    options

dsl = new DSL

exports.matchers = dsl.matchers

exports.run = -> dsl.run.apply dsl, arguments
exports.loadConfigFile = -> dsl.runFile.apply dsl, arguments
exports.loadYamlConfigFile = (path, options) ->
  yaml = new YamlConfig(path, options)
  yaml.toOptions()
