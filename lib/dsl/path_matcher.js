(function() {
  var path, _;
  _ = require('underscore');
  path = require('path');
  exports.PathMatcher = (function() {
    function PathMatcher(filePattern) {
      filePattern = _.flatten([filePattern]);
      this.options = {
        filePattern: filePattern
      };
    }
    PathMatcher.prototype.use = function(compiler, options) {
      if (options == null) {
        options = {};
      }
      this.name = compiler;
      _.extend(this.options, options);
      return this;
    };
    PathMatcher.prototype.output = function(filePath) {
      return this.options.output = filePath;
    };
    return PathMatcher;
  })();
}).call(this);
