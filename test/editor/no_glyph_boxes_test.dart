import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

void main() {
  Future<RenderEditor> pumpEditor(WidgetTester tester, String text) async {
    final controller = QuillController.basic()..document.insert(0, text);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      QuillTestApp.withScaffold(QuillEditor.basic(controller: controller)),
    );
    await tester.pumpAndSettle();
    return tester.allRenderObjects.whereType<RenderEditor>().first;
  }

  testWidgets(
    'getEndpointsForSelection does not crash when an edge is inside an emoji',
    (tester) async {
      final editor = await pumpEditor(tester, '\u{1F44D} thumbs up');
      final endpoints = editor.getEndpointsForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 1),
      );
      expect(endpoints, hasLength(2));
    },
  );

  testWidgets('getLineAtOffset collapses to the caret on an empty line', (
    tester,
  ) async {
    final editor = await pumpEditor(tester, '\nsecond line');
    final line = editor.getLineAtOffset(const TextPosition(offset: 0));
    expect(line, const TextSelection.collapsed(offset: 0));
  });
}
