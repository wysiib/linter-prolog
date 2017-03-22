module.exports = LinterProlog =
  config:
    compilerPath:
      title: 'Compiler Executable Path'
      description: 'The path to swipl or sicstus'
      type: 'string'
      default: 'swipl'
  activate: ->
    require("atom-package-deps").install("linter-prolog")

  provideLinter: ->
    LinterProvider = require './linter-provider'
    provider = new LinterProvider()
    return {
      grammarScopes: ['source.prolog']
      scope: 'file'
      lint: provider.lint
      lintsOnChange: false
      name: 'SWI / SICStus Prolog'
    }
