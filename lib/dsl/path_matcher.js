(function() {
  var path, _;
  _ = require('underscore');
  path = require('path');
  exports.PathMatcher = (function() {
    function PathMatcher(rootPath, filePattern) {
      filePattern = _.flatten([filePattern]);
      this.rootPath = rootPath;
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
    PathMatcher.prototype.output = function(file) {
      return this.options.output = path.resolve(this.rootPath, file);
    };
    return PathMatcher;
  })();
}).call(this);
