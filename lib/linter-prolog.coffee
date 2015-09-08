module.exports = LinterProlog =
  config:
    compilerPath:
      title: 'Compiler Executable Path'
      description: 'The path to swipl or sicstus'
      type: 'string'
      default: 'swipl'
  activate: ->
    require("atom-package-dependencies").install();

  provideLinter: ->
    LinterProvider = require './linter-provider'
    provider = new LinterProvider()
    return {
      grammarScopes: ['source.prolog']
      scope: 'file'
      lint: provider.lint
      lintOnFly: false
    }
