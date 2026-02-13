import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomShortcut extends ShortcutActivator {
  final ShortcutActivator activator;

  const CustomShortcut(this.activator);

  @override
  bool accepts(KeyEvent event, HardwareKeyboard state) {
    // 1. Check if the key itself matches (e.g., is it Backspace?)
    if (!activator.accepts(event, state)) {
      return false;
    }

    // 2. Check if we are currently editing text
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext != null) {
      final isEditing =
          focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
      // If we are editing, we REJECT the shortcut, allowing the
      // key to continue to the text field naturally.
      if (isEditing) {
        return false;
      }
    }

    return true;
  }

  @override
  String debugDescribeKeys() {
    return activator.debugDescribeKeys();
  }
}
