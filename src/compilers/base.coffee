_ = require 'underscore'
path = require 'path'
fs = require 'fs'
helpers = require '../helpers'
fileUtil = require 'file'

class exports.Compiler

  constructor: (@options) ->
    @rootPath = @options.rootPath || process.cwd()

  filePattern: ->
    @options.filePattern

  matchesFile: (file) ->
    _.any(@filePattern(), (pattern) -> file.match(pattern))

  # should be overwritten by every compiler subclass
  compile: (files) -> #NOOP

  # generates path suitable for useage within the compiler
  # should be used prior every file handling done within the compiler
  generatePath: (dirPath) ->
    path.resolve @rootPath, dirPath

  # writes content to file - creates intermediate directories as needed
  writeToFile: (filePath, content, callback) ->
    filePath = @generatePath filePath
    dirPath = path.dirname(filePath)
    fileUtil.mkdirs dirPath, 0755, (err) =>
      if err?
        helpers.log "brunch:   #{colors.lred('Couldn\'t create build path.', true)}\n"
        helpers.log "#{colors.lgray(err, true)}\n"
        callback err if callback?
      else
        fs.writeFile(filePath, content, (err) =>
          if err?
            helpers.log "brunch:   #{colors.lred('Couldn\'t write compiled file.', true)}\n"
            helpers.log "#{colors.lgray(err, true)}\n"
          callback err if callback?
        )

  # can be overwritten to change behavior on file changed events
  # by default waits 20ms for file events then calls compile with all changed files
  fileChanged: (file) ->
    @changedFiles ?= []
    @changedFiles.push(file)
    clearTimeout(@timeout)
    @timeout = setTimeout( =>
      _.bind(@compile, @, @changedFiles)()
      @changedFiles = undefined
    , 20)
