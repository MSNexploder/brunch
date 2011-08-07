(function() {
  var _;
  _ = require('underscore');
  exports.PathMatcher = (function() {
    function PathMatcher(filePattern) {
      filePattern = _.isArray(filePattern) ? filePattern : [filePattern];
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
    PathMatcher.prototype.output = function(path) {
      return this.options.output = path;
    };
    return PathMatcher;
  })();
}).call(this);
