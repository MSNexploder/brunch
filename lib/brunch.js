(function() {
  var colors, compilers, fileUtil, fs, helpers, path, _;
  _ = require('underscore');
  fs = require('fs');
  path = require('path');
  helpers = require('./helpers');
  fileUtil = require('file');
  colors = require('../vendor/termcolors').colors;
  exports.VERSION = require('./package').version;
  exports.ROOT_PATH = '.';
  compilers = [];
  exports["new"] = function(root_path, callback) {
    var template_path;
    template_path = path.join(module.id, "/../../template/base");
    return path.exists(root_path, function(exists) {
      if (exists) {
        helpers.log(colors.lred("brunch:   directory already exists - can't create a project in there\n", true));
        process.exit(0);
      }
      fileUtil.mkdirsSync(root_path, 0755);
      return helpers.recursiveCopy(template_path, root_path, function() {
        exports.createExampleIndex(path.join(root_path, 'index.html'), callback);
        return helpers.log("brunch:   " + (colors.green('created ', true)) + " brunch directory layout\n");
      });
    });
  };
  exports.watch = function(options) {
    exports.initializeCompilers(options);
    return helpers.watchDirectory({
      path: path.join(options.rootPath, 'src'),
      callOnAdd: true
    }, function(file) {
      return exports.dispatch(file);
    });
  };
  exports.build = function(options) {
    var compiler, _i, _len, _results;
    exports.initializeCompilers(options);
    _results = [];
    for (_i = 0, _len = compilers.length; _i < _len; _i++) {
      compiler = compilers[_i];
      _results.push(compiler.compile(['.']));
    }
    return _results;
  };
  exports.createExampleIndex = function(filePath, callback) {
    var index;
    index = "<!doctype html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\">\n  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">\n  <link rel=\"stylesheet\" href=\"build/web/css/main.css\" type=\"text/css\" media=\"screen\">\n  <script src=\"build/web/js/app.js\"></script>\n  <script>require('main');</script>\n</head>\n<body>\n</body>\n</html>";
    return fs.writeFile(filePath, index, callback);
  };
  exports.initializeCompilers = function(options) {
    var compiler, name, settings;
    return compilers = (function() {
      var _results;
      _results = [];
      for (name in options) {
        settings = options[name];
        if (_.include(['buildPath', 'rootPath'], name)) {
          continue;
        }
        compiler = require('./compilers')[["" + (helpers.capitalize(name)) + "Compiler"]];
        _results.push(new compiler(options));
      }
      return _results;
    })();
  };
  exports.dispatch = function(file) {
    var compiler, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = compilers.length; _i < _len; _i++) {
      compiler = compilers[_i];
      _results.push(compiler.matchesFile(file) ? compiler.fileChanged(file) : void 0);
    }
    return _results;
  };
}).call(this);
