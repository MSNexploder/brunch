require.paths.unshift __dirname + "/../lib"

testCase = require('nodeunit').testCase
StitchCompiler = require('compilers').StitchCompiler

module.exports = testCase(
  'creates a valid stitch package': (test) ->
    test.expect 2

    options = {}
    options.dependencies = [
      'ConsoleDummy.js',
      'jquery-1.6.2.js',
      'underscore-1.1.7.js',
      'backbone-0.5.2.js'
    ]

    compiler = new StitchCompiler options

    original_path = process.cwd()
    process.chdir 'test/fixtures/base'

    package = compiler.package()
    test.deepEqual package.paths, ['src/app/']
    test.strictEqual package.dependencies[0], 'src/vendor/ConsoleDummy.js'

    process.chdir original_path
    test.done()
)
