import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

void main() {
  testWidgets('selecting across an empty line does not throw', (tester) async {
    // TextPainter returns a fixed-length box list when the line has a paint
    // offset (non-left-aligned line re-laid out at a new width). Adding the
    // empty-line marker rect to it used to throw on paint.
    final controller = QuillController.basic()
      ..document.insert(0, 'first\n\nthird')
      ..formatText(6, 0, Attribute.centerAlignment);
    addTearDown(controller.dispose);

    Widget editorWithWidth(double width) => QuillTestApp.withScaffold(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: QuillEditor.basic(controller: controller),
        ),
      ),
    );

    await tester.pumpWidget(editorWithWidth(400));
    await tester.pumpAndSettle();
    await tester.pumpWidget(editorWithWidth(300));
    await tester.pumpAndSettle();

    controller.updateSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: controller.document.length - 1,
      ),
      ChangeSource.local,
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
