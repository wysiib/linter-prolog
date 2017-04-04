"use babel";

describe('The prolog-linter for AtomLinter', () => {
  const lint = require('../lib/linter-prolog').provideLinter().lint;

  beforeEach(() => {
    waitsForPromise(() => {
      return atom.packages.activatePackage("linter-prolog");
    });
  });

  it('finds a simple syntax error', () => {
    waitsForPromise(() => {
      return atom.workspace.open(__dirname + '/test_files/simple_syntax_error.pl').then(editor => {
        return lint(editor).then(messages => {
          expect(messages.length).toEqual(1);
          expect(messages[0].severity).toBeDefined();
          expect(messages[0].severity).toEqual('error');
          expect(messages[0].excerpt).toBeDefined();
          expect(messages[0].excerpt).toEqual('Syntax error: Unexpected end of file');
          expect(messages[0].location.file).toBeDefined();
          expect(messages[0].location.file).toMatch(/.+simple_syntax_error\.pl$/);
          expect(messages[0].location.position).toBeDefined();
          expect(messages[0].location.position.length).toEqual(2);
          expect(messages[0].location.position).toEqual([[0, 7], [0, 7]]);
        });
      });
    });
  });

  it('finds nothing wrong with an empty file', () => {
    waitsForPromise(() => {
      return atom.workspace.open(__dirname + '/test_files/empty.pl').then(editor => {
        return lint(editor).then(messages => {
          expect(messages.length).toEqual(0);
        });
      });
    });
  });

  it('finds nothing wrong with a simple implementation of append', () => {
    waitsForPromise(() => {
      return atom.workspace.open(__dirname + '/test_files/append.pl').then(editor => {
        return lint(editor).then(messages => {
          expect(messages.length).toEqual(0);
        });
      });
    });
  });

  it('find errors in filepath with whitespace', () => {
    waitsForPromise(() => {
      return atom.workspace.open(__dirname + '/test_files/file space.pl').then(editor => {
        return lint(editor).then(messages => {
          expect(messages.length).toEqual(1);
        });
      });
    });
  });

  it('finds singleton variable warnings', () => {
    waitsForPromise(() => {
      return atom.workspace.open(__dirname + '/test_files/singleton_warning.pl').then(editor => {
        return lint(editor).then(messages => {
          expect(messages.length).toEqual(1);
          expect(messages[0].severity).toBeDefined();
          expect(messages[0].severity).toEqual('warning');
          expect(messages[0].excerpt).toBeDefined();
          expect(messages[0].excerpt).toEqual('Singleton variables: [X]');
          expect(messages[0].location.file).toBeDefined();
          expect(messages[0].location.file).toMatch(/.+singleton_warning\.pl$/);
          expect(messages[0].location.position).toBeDefined();
          expect(messages[0].location.position.length).toEqual(2);
          expect(messages[0].location.position).toEqual([[0, 0], [0, 0]]);
        });
      });
    });
  });
});
