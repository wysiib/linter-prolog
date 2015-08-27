module.exports = LinterProlog =
  config:
    compilerPath:
      title: 'Compiler Executable Path'
      description: 'The path to swipl or sicstus'
      type: 'string'
      default: 'swipl'
  activate: ->
    atom.notification.addError(
      'Prolog Language Package not found.',
      {detail: 'Please install the `language-prolog` package in your Settings view.'}
    ) unless atom.packages.getLoadedPackages 'language-prolog'

  provideLinter: ->
    LinterProvider = require './linter-provider'
    provider = new LinterProvider()
    return {
      grammarScopes: ['source.prolog']
      scope: 'file'
      lint: provider.lint
      lintOnFly: false
    }
