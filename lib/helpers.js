(function() {
  var async, coffeescript_support, fileUtil, fs, path, spawn, sys, _;
  fs = require('fs');
  path = require('path');
  spawn = require('child_process').spawn;
  async = require('async');
  fileUtil = require('file');
  _ = require('underscore');
  sys = require('sys');
  coffeescript_support = "var __slice = Array.prototype.slice;\nvar __hasProp = Object.prototype.hasOwnProperty;\nvar __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };\nvar __extends = function(child, parent) {\n  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }\n  function ctor() { this.constructor = child; }\n  ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype;\n  return child;\n};\nvar __indexOf = Array.prototype.indexOf || function(item) {\n  for (var i = 0, l = this.length; i < l; i++) {\n    if (this[i] === item) return i;\n  }\n  return -1;\n};";
  exports.copyFile = function(source, destination, callback) {
    var read, write;
    read = fs.createReadStream(source);
    write = fs.createWriteStream(destination);
    return sys.pump(read, write, function() {
      return callback();
    });
  };
  exports.walkTreeAndCopyFiles = function(source, destination, callback) {
    return fs.readdir(source, function(err, files) {
      if (err) {
        return callback(err);
      }
      return async.forEach(files, function(file, next) {
        var destinationPath, sourcePath;
        if (file.match(/^\./)) {
          return next();
        }
        sourcePath = path.join(source, file);
        destinationPath = path.join(destination, file);
        return fs.stat(sourcePath, function(err, stats) {
          if (!err && stats.isDirectory()) {
            return fs.mkdir(destinationPath, 0755, function() {
              return exports.walkTreeAndCopyFiles(sourcePath, destinationPath, function(err, destinationPath) {
                if (destinationPath) {
                  return callback(err, destinationPath);
                } else {
                  return next();
                }
              });
            });
          } else {
            return exports.copyFile(sourcePath, destinationPath, function() {
              callback(err, destinationPath);
              return next();
            });
          }
        });
      }, callback);
    });
  };
  exports.recursiveCopy = function(source, destination, callback) {
    var paths;
    fileUtil.mkdirsSync(destination, 0755);
    paths = [];
    return exports.walkTreeAndCopyFiles(source, destination, function(err, filename) {
      if (err) {
        return callback(err);
      } else if (filename) {
        return paths.push(filename);
      } else {
        return callback(err, paths.sort());
      }
    });
  };
  exports.watchDirectory = function(_opts, callback) {
    var addToWatch, opts, watched;
    opts = _.extend({
      path: '.',
      persistent: true,
      interval: 500,
      callOnAdd: false
    }, _opts);
    watched = [];
    addToWatch = function(file) {
      return fs.realpath(file, function(err, filePath) {
        var callOnAdd, isDir;
        callOnAdd = opts.callOnAdd;
        if (!_.include(watched, filePath)) {
          isDir = false;
          watched.push(filePath);
          fs.watchFile(filePath, {
            persistent: opts.persistent,
            interval: opts.interval
          }, function(curr, prev) {
            if (curr.mtime.getTime() === prev.mtime.getTime()) {
              return;
            }
            if (isDir) {
              return addToWatch(filePath);
            } else {
              return callback(filePath);
            }
          });
        } else {
          callOnAdd = false;
        }
        return fs.stat(filePath, function(err, stats) {
          if (stats.isDirectory()) {
            isDir = true;
            return fs.readdir(filePath, function(err, files) {
              return process.nextTick(function() {
                var file, _i, _len, _results;
                _results = [];
                for (_i = 0, _len = files.length; _i < _len; _i++) {
                  file = files[_i];
                  _results.push(addToWatch(filePath + '/' + file));
                }
                return _results;
              });
            });
          } else {
            if (callOnAdd) {
              return callback(filePath);
            }
          }
        });
      });
    };
    return addToWatch(opts.path);
  };
  exports.filterFiles = function(files, sourcePath) {
    return _.select(files, function(filename) {
      var filePath, stats;
      if (filename.match(/^\./)) {
        return false;
      }
      filePath = path.join(sourcePath, filename);
      stats = fs.statSync(filePath);
      if (stats != null ? stats.isDirectory() : void 0) {
        return false;
      }
      return true;
    });
  };
  exports.optionsInfo = function(options) {
    var option, output;
    output = "\n\nAvailable options:\n";
    for (option in options) {
      output += "  " + options[option].string + "    " + options[option].help + "\n";
    }
    return output;
  };
  exports.log = function(info, options) {
    var d, timestamp;
    d = new Date();
    timestamp = exports.formatIsodate(d);
    return process.stdout.write(timestamp + " " + info);
  };
  exports.formatIsodate = function(d) {
    var pad;
    pad = function(n) {
      if (n < 10) {
        return '0' + n;
      } else {
        return n;
      }
    };
    return d.getUTCFullYear() + '-' + pad(d.getUTCMonth() + 1) + '-' + pad(d.getUTCDate()) + 'T' + pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes()) + ':' + pad(d.getUTCSeconds()) + 'Z';
  };
  exports.scoped = function(code) {
    code = String(code);
    if (code.indexOf('function') !== 0) {
      code = "function () {" + code + "}";
    }
    code = "" + coffeescript_support + " with(locals) {return (" + code + ").apply(context, args);}";
    return new Function('context', 'locals', 'args', code);
  };
}).call(this);
