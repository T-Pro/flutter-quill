import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'a dirty editor that loses focus does not take it back',
    (tester) async {
      final first = QuillController.basic()..document.insert(0, 'first');
      final second = QuillController.basic()..document.insert(0, 'second');
      final firstFocus = FocusNode();
      final secondFocus = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(firstFocus.dispose);
      addTearDown(secondFocus.dispose);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates:
              FlutterQuillLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Column(
              children: [
                QuillEditor.basic(controller: first, focusNode: firstFocus),
                QuillEditor.basic(controller: second, focusNode: secondFocus),
              ],
            ),
          ),
        ),
      );
      firstFocus.requestFocus();
      await tester.pumpAndSettle();
      expect(firstFocus.hasPrimaryFocus, isTrue);

      // The loop runs in microtasks and starves the test timeout, so stop it
      // by hand once focus has clearly bounced.
      var focusChanges = 0;
      void bound() {
        if (++focusChanges > 20) {
          firstFocus.canRequestFocus = false;
          secondFocus.canRequestFocus = false;
        }
      }

      FocusManager.instance.addListener(bound);
      addTearDown(() => FocusManager.instance.removeListener(bound));

      // Both editors change selection, so both are dirty until the next
      // build, and focus moves before that build runs.
      first.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      second.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      secondFocus.requestFocus();
      await tester.pumpAndSettle();

      expect(focusChanges, lessThanOrEqualTo(2),
          reason: 'focus bounced between the editors');
      expect(secondFocus.hasPrimaryFocus, isTrue);
    },
  );
}
