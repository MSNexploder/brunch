(function() {
  var fileUtil, fs, helpers, path, _;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  _ = require('underscore');
  path = require('path');
  fs = require('fs');
  helpers = require('../helpers');
  fileUtil = require('file');
  exports.Compiler = (function() {
    function Compiler(options) {
      this.options = options;
    }
    Compiler.prototype.filePattern = function() {
      return [];
    };
    Compiler.prototype.matchesFile = function(file) {
      return _.any(this.filePattern(), function(pattern) {
        return file.match(pattern);
      });
    };
    Compiler.prototype.compile = function(files) {};
    Compiler.prototype.writeToFile = function(filePath, content, callback) {
      var dirPath;
      dirPath = path.dirname(filePath);
      return fileUtil.mkdirs(dirPath, 0755, __bind(function(err) {
        if (err != null) {
          helpers.log("brunch:   " + (colors.lred('Couldn\'t create build path.', true)) + "\n");
          helpers.log("" + (colors.lgray(err, true)) + "\n");
          if (callback != null) {
            return callback(err);
          }
        } else {
          return fs.writeFile(filePath, content, __bind(function(err) {
            if (err != null) {
              helpers.log("brunch:   " + (colors.lred('Couldn\'t write compiled file.', true)) + "\n");
              helpers.log("" + (colors.lgray(err, true)) + "\n");
            }
            if (callback != null) {
              return callback(err);
            }
          }, this));
        }
      }, this));
    };
    Compiler.prototype.fileChanged = function(file) {
      var _ref;
      if ((_ref = this.changedFiles) == null) {
        this.changedFiles = [];
      }
      this.changedFiles.push(file);
      clearTimeout(this.timeout);
      return this.timeout = setTimeout(__bind(function() {
        _.bind(this.compile, this, this.changedFiles)();
        return this.changedFiles = void 0;
      }, this), 20);
    };
    return Compiler;
  })();
}).call(this);
