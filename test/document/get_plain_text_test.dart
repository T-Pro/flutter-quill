import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:test/test.dart';

// Regression tests for https://github.com/singerdmx/flutter-quill/issues/2704
void main() {
  group('getPlainText past the end of the document', () {
    test('single line is not repeated', () {
      final document = Document()..insert(0, 'This is string 1');
      expect(document.getPlainText(0, 50), 'This is string 1\n');
    });

    test('blank document returns its trailing newline once', () {
      expect(Document().getPlainText(0, 50), '\n');
    });

    test('multi-line document is not repeated', () {
      final document = Document.fromDelta(Delta()..insert('one\n\ntwo\n'));
      expect(document.getPlainText(0, 100), 'one\n\ntwo\n');
    });

    test('starting mid-document returns only the remainder', () {
      final document = Document.fromDelta(Delta()..insert('one\ntwo\n'));
      expect(document.getPlainText(5, 100), 'wo\n');
    });

    test('lines inside a block are not repeated', () {
      final document = Document.fromDelta(
        Delta()
          ..insert('one\ntwo')
          ..insert('\n', {'list': 'bullet'})
          ..insert('three\n'),
      );
      expect(document.getPlainText(0, 100), 'one\ntwo\nthree\n');
    });

    test('embeds are not repeated', () {
      final document = Document.fromDelta(
        Delta()
          ..insert('a\n')
          ..insert({'image': 'x.png'})
          ..insert('\nb\n'),
      );
      expect(
        document.getPlainText(0, 100),
        'a\n${Embed.kObjectReplacementCharacter}\nb\n',
      );
    });

    test('exact length is unchanged', () {
      final document = Document.fromDelta(Delta()..insert('one\ntwo\n'));
      expect(document.getPlainText(0, document.length), 'one\ntwo\n');
    });
  });
}
