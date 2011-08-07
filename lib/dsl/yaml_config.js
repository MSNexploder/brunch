(function() {
  var dsl, fs, util, yaml, _;
  _ = require('underscore');
  yaml = require('yaml');
  fs = require('fs');
  util = require('util');
  dsl = require('./index');
  exports.YamlConfig = (function() {
    function YamlConfig(path, options) {
      this.path = path;
      this.options = options;
      this.data = yaml.eval(fs.readFileSync(path, 'utf8'));
    }
    YamlConfig.prototype.toOptions = function() {
      var config_string, options;
      _.defaults(this.data, this.options.stitch);
      config_string = "files([/\\.styl$/]).use('stylus')\nfiles([/\\.coffee$/, /src\\/.*\\.js$/, new RegExp(\"" + this.data.templateExtension + "$\")])\n  .use('stitch', { minify: " + this.data.minify + ", dependencies: " + (util.inspect(this.data.dependencies)) + " })";
      options = dsl.run(config_string);
      options.buildPath = this.data.buildPath || this.options.buildPath;
      options.rootPath = this.options.rootPath;
      return options;
    };
    return YamlConfig;
  })();
}).call(this);
