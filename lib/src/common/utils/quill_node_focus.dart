import 'package:flutter/widgets.dart';

class QuillFocusNode extends FocusNode {

  QuillFocusNode({
    super.debugLabel,
    @Deprecated(
      'Use onKeyEvent instead. '
      'This feature was deprecated after v3.18.0-2.0.pre.',
    )
    super.onKey,
    super.onKeyEvent,
    super.skipTraversal,
    super.canRequestFocus,
    super.descendantsAreFocusable,
    super.descendantsAreTraversable,
    bool keyboardEnabled = true,
  }) : _keyboardEnabled = keyboardEnabled;

  bool _keyboardEnabled = true;

  bool get keyboardEnabled => _keyboardEnabled;

  set keyboardEnabled(bool value) {
    if (_keyboardEnabled != value) {
      _keyboardEnabled = value;
      // Required otherwise the keyboard doesn't close/open automatically.
      unfocus();
      // Required otherwise requestFocus() does nothing and the previously caret
      // position is not shown.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        requestFocus();
      });
    }
  }
}
