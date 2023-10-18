import 'package:flutter/material.dart';
import 'package:pivotpay/utils/session_timer.dart';

mixin BasicPage<Page extends BasePage> on BaseState<Page> {
  @override
  static final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: SessionTimer().userActivityDetected,
      child: rootWidget(context),
    );
  }

  Widget rootWidget(BuildContext context);
}

abstract class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);
}

abstract class BaseState<Page extends BasePage> extends State<Page> {}