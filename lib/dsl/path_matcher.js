(function() {
  var capitalize, _;
  _ = require('underscore');
  capitalize = require('../helpers').capitalize;
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
      return this;
    };
    PathMatcher.prototype.output = function(path) {
      return this.options.output = path;
    };
    return PathMatcher;
  })();
}).call(this);
