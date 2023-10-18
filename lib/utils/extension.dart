import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double getHeight({double factor = 1}) {
    assert(factor != 0);
    return MediaQuery.of(this).size.height * factor;
  }

  double getWidth({double factor = 1}) {
    assert(factor != 0);
    return MediaQuery.of(this).size.width * factor;
  }

  double get height => getHeight();
  double get width => getWidth();

  bool get mounted {
    try {
      widget;
      return true;
    } catch (e) {
      return false;
    }
  }
}

extension ClickableExtension on Widget {
  Widget onTap(void Function() action, {bool opaque = true}) {
    return GestureDetector(
      behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onTap: action,
      child: this,
    );
  }
}
