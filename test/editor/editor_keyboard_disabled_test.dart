import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('no input connection is attached while keyboard is disabled', (
    tester,
  ) async {
    final controller = QuillController.basic()..document.insert(0, 'text');
    final focusNode = QuillFocusNode(keyboardEnabled: false);
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditor.basic(controller: controller, focusNode: focusNode),
        ),
      ),
    );

    final log = tester.testTextInput.log;
    bool sent(String method) => log.any((call) => call.method == method);

    controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    focusNode.requestFocus();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(focusNode.hasFocus, isTrue);
    expect(sent('TextInput.setClient'), isFalse);
    expect(sent('TextInput.show'), isFalse);

    focusNode.keyboardEnabled = true;
    // The setter unfocuses, then refocuses in a post-frame callback.
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(focusNode.hasFocus, isTrue);
    expect(sent('TextInput.setClient'), isTrue);
    expect(sent('TextInput.show'), isTrue);
    expect(controller.selection.baseOffset, 2);

    log.clear();
    focusNode.keyboardEnabled = false;
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(focusNode.hasFocus, isTrue);
    expect(sent('TextInput.clearClient'), isTrue);
    expect(sent('TextInput.setClient'), isFalse);
  });
}
