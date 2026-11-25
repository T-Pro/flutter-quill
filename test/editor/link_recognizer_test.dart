import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

void main() {
  GestureRecognizer? findSpanRecognizer(WidgetTester tester, String text) {
    GestureRecognizer? found;
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text == text) {
          found = span.recognizer;
          return false;
        }
        return true;
      });
    }
    return found;
  }

  testWidgets('long-pressing text after removing a link does not throw', (
    tester,
  ) async {
    final controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('linktext', {'link': 'https://example.com'})
          ..insert('\n'),
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      QuillTestApp.withScaffold(QuillEditor.basic(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      findSpanRecognizer(tester, 'linktext'),
      isA<LongPressGestureRecognizer>(),
    );

    controller.formatText(0, 8, const LinkAttribute(null));
    await tester.pumpAndSettle();

    expect(findSpanRecognizer(tester, 'linktext'), isNull);

    await tester.longPress(find.textContaining('linktext', findRichText: true));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  }, variant: const TargetPlatformVariant({TargetPlatform.android}));
}
