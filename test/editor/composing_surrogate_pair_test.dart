import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

void main() {
  testWidgets('composing range splitting an emoji surrogate pair does not '
      'crash layout', (tester) async {
    // The emoji occupies code units 2 and 3.
    final controller = QuillController.basic()
      ..document.insert(0, 'ab\u{1F600}cd');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      QuillTestApp.withScaffold(
        QuillEditor.basic(
          controller: controller,
          config: const QuillEditorConfig(autoFocus: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Composing end 3 lands between the high and low surrogate.
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: controller.document.toPlainText(),
        selection: const TextSelection.collapsed(offset: 2),
        composing: const TextRange(start: 0, end: 3),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Clear composing so teardown does not notify a defunct element.
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: controller.document.toPlainText(),
        selection: const TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.pumpAndSettle();
  });
}
