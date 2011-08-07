(function() {
  var _;
  _ = require('underscore');
  exports.PathMatcher = (function() {
    function PathMatcher(paths) {
      paths = _.isArray(paths) ? paths : [paths];
      this.options = {
        paths: paths
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
