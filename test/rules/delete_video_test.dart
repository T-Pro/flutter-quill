import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/rules/delete.dart';
import 'package:test/test.dart';

void main() {
  group('EnsureEmbedLineRule', () {
    const rule = EnsureEmbedLineRule();

    Document embedLines(String type) => Document.fromDelta(
      Delta()
        ..insert(<String, String>{type: 'a'})
        ..insert('\n')
        ..insert(<String, String>{type: 'b'})
        ..insert('\n'),
    );

    test('Applies when merging video lines', () {
      expect(rule.apply(embedLines('video'), 1, len: 1), isNotNull);
    });

    test('Does not apply to image lines', () {
      expect(rule.apply(embedLines('image'), 1, len: 1), isNull);
    });
  });
}
