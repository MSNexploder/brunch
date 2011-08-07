(function() {
  var dsl, fs, path, util, yaml, _;
  _ = require('underscore');
  yaml = require('yaml');
  fs = require('fs');
  path = require('path');
  util = require('util');
  dsl = require('./index');
  exports.YamlConfig = (function() {
    function YamlConfig(path, options) {
      this.path = path;
      this.options = options;
      this.data = yaml.eval(fs.readFileSync(path, 'utf8'));
    }
    YamlConfig.prototype.toOptions = function() {
      var config_string, options, _base, _ref;
      _.defaults(this.data, this.options.stitch);
      if ((_ref = (_base = this.data).buildPath) == null) {
        _base.buildPath = this.options.buildPath;
      }
      this.data.rootPath = this.options.rootPath;
      config_string = "files([/\\.styl$/]).use('stylus').output('" + (path.join(this.data.buildPath, 'web/css/main.css')) + "')\nfiles([/\\.coffee$/, /src\\/.*\\.js$/, new RegExp(\"" + this.data.templateExtension + "$\")])\n  .use('stitch', { minify: " + this.data.minify + ", dependencies: " + (util.inspect(this.data.dependencies)) + " })\n  .output('" + (path.join(this.data.buildPath, 'web/js/app.js')) + "')";
      options = dsl.run(config_string);
      options.buildPath = this.data.buildPath;
      options.rootPath = this.data.rootPath;
      return options;
    };
    return YamlConfig;
  })();
}).call(this);
