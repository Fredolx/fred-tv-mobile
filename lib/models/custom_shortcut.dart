import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomShortcut extends ShortcutActivator {
  final ShortcutActivator activator;

  const CustomShortcut(this.activator);

  @override
  bool accepts(KeyEvent event, HardwareKeyboard state) {
    if (!activator.accepts(event, state)) {
      return false;
    }

    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext != null) {
      final isEditing =
          focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
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
