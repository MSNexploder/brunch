require.paths.unshift __dirname + "/../lib"

testCase = require('nodeunit').testCase
path = require 'path'
StitchCompiler = require('compilers').StitchCompiler

module.exports = testCase(
  'creates a valid stitch package': (test) ->
    test.expect 2

    options =
      rootPath: 'test/fixtures/base'
      dependencies: [
        'ConsoleDummy.js'
        'jquery-1.6.2.js'
        'underscore-1.1.7.js'
        'backbone-0.5.2.js'
      ]

    compiler = new StitchCompiler options

    package = compiler.package()
    test.deepEqual package.paths, [path.resolve('test/fixtures/base/src/app/')]
    test.strictEqual package.dependencies[0], path.resolve('test/fixtures/base/src/vendor/ConsoleDummy.js')
    test.done()
)
