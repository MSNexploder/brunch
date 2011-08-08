fs        = require 'fs'
path      = require 'path'
spawn     = require('child_process').spawn
async     = require 'async'
fileUtil  = require 'file'
_         = require 'underscore'
sys       = require 'sys'

coffeescript_support = """
  var __slice = Array.prototype.slice;
  var __hasProp = Object.prototype.hasOwnProperty;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  var __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype;
    return child;
  };
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
"""

# copy single file and executes callback when done
exports.copyFile = (source, destination, callback) ->
  read = fs.createReadStream source
  write = fs.createWriteStream destination
  sys.pump read, write, ->
    callback()

# walk through tree, creates directories and copy files
exports.walkTreeAndCopyFiles = (source, destination, callback) ->
  fs.readdir source, (err, files) ->
    return callback err if err

    # iterates over current directory
    async.forEach files, (file, next) ->
      return next() if file.match /^\./

      sourcePath = path.join source, file
      destinationPath = path.join destination, file

      fs.stat sourcePath, (err, stats) ->
        if !err and stats.isDirectory()
          fs.mkdir destinationPath, 0755, ->
            exports.walkTreeAndCopyFiles sourcePath, destinationPath, (err, destinationPath) ->
              if destinationPath
                callback err, destinationPath
              else
                next()
        else
          exports.copyFile sourcePath, destinationPath, ->
            callback err, destinationPath
            next()
    , callback

# recursive copy file tree from source to destination and fires
# callback with error and a list of created files
exports.recursiveCopy = (source, destination, callback) ->
  fileUtil.mkdirsSync destination, 0755
  paths = []
  # callback will be called several times
  exports.walkTreeAndCopyFiles source, destination, (err, filename) ->
    if err
      callback err
    else if filename
      paths.push filename
    else
      callback err, paths.sort()

# copied source from watch_dir, because it did not work as package
exports.watchDirectory = (_opts, callback) ->
  opts = _.extend(
    { path: '.', persistent: true, interval: 500, callOnAdd: false },
    _opts
  )
  watched = []
  addToWatch = (file) ->
    fs.realpath file, (err, filePath) ->
      callOnAdd = opts.callOnAdd

      unless _.include(watched, filePath)
        isDir = false
        watched.push filePath
        fs.watchFile filePath, { persistent: opts.persistent, interval: opts.interval }, (curr, prev) ->
          return if curr.mtime.getTime() is prev.mtime.getTime()
          if isDir
            addToWatch filePath
          else
            callback filePath
      else
        callOnAdd = false

      fs.stat filePath, (err, stats) ->
        if stats.isDirectory()
          isDir = true
          fs.readdir filePath, (err, files) ->
            process.nextTick () ->
              addToWatch filePath + '/' + file for file in files
        else
          callback filePath if callOnAdd
  addToWatch opts.path

# filter out dotfiles and directories
exports.filterFiles = (files, sourcePath) ->
  _.select files, (filename) ->
    return false if filename.match /^\./
    filePath = path.join(sourcePath, filename)
    stats = fs.statSync filePath
    return false if stats?.isDirectory()
    true

# return a string of available options
# originally taken from nomnom helpString
exports.optionsInfo = (options) ->
  output = "\n\nAvailable options:\n"
  for option of options
    output += "  #{ options[option].string }    #{options[option].help}\n"
  output

exports.log = (info, options) ->
  d = new Date()
  timestamp = exports.formatIsodate(d)
  process.stdout.write timestamp + " " + info

# iso date formatting taken from
# https://developer.mozilla.org/en/Core_JavaScript_1.5_Reference:Global_Objects:Date#Example.3a_ISO_8601_formatted_dates
exports.formatIsodate = (d) ->
  pad = (n) ->
    if n<10
      '0'+n
    else
      n
  d.getUTCFullYear()+'-'+ pad(d.getUTCMonth()+1)+'-'+ pad(d.getUTCDate())+'T'+ pad(d.getUTCHours())+':'+ pad(d.getUTCMinutes())+':'+ pad(d.getUTCSeconds())+'Z'

# scopes given code into a new function
exports.scoped = (code) ->
  code = String(code)
  code = "function () {#{code}}" unless code.indexOf('function') is 0
  code = "#{coffeescript_support} with(locals) {return (#{code}).apply(context, args);}"
  new Function('context', 'locals', 'args', code)

# converts the first character to uppercase and the remainder to lowercase
exports.capitalize = (word) -> (word[0] || '').toUpperCase() + (word[1..-1] || '').toLowerCase()
