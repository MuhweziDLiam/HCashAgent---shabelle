import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef Widget PageBuilder();

class PageRouter {
  static const double kDefaultDuration = .25;

  static Route<T> fadeThrough<T>(PageBuilder pageBuilder,
      [double duration = kDefaultDuration,]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => pageBuilder(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,);
      },
    );
  }

  static Route<T> fadeScale<T>(PageBuilder pageBuilder,
      [double duration = kDefaultDuration,]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => pageBuilder(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(animation: animation, child: child);
      },
    );
  }
}
