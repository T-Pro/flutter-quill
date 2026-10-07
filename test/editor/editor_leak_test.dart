import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() {
  LeakTesting.enable();

  testWidgets(
    'QuillEditor does not leak after unmount while focused with a selection',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      final controller = QuillController.basic()
        ..document.insert(0, 'hello world');
      final focusNode = FocusNode();
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
          home: Scaffold(
            body: QuillEditor(
              controller: controller,
              focusNode: focusNode,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      controller.updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 5),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'QuillEditor.basic disposes its own focus node and scroll controller',
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
    (tester) async {
      final controller = QuillController.basic();
      addTearDown(controller.dispose);

      Widget app() => MaterialApp(
            localizationsDelegates:
                FlutterQuillLocalizations.localizationsDelegates,
            home: QuillEditor.basic(controller: controller),
          );

      await tester.pumpWidget(app());
      await tester.pumpWidget(app());
      await tester.pumpWidget(const SizedBox());
    },
  );
}
