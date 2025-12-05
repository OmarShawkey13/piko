import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  void push<ARG>(String routeName, {ARG? arguments}) =>
      Navigator.pushNamed(this, routeName, arguments: arguments);

  void pushReplacement<ARG>(String routeName, {ARG? arguments}) =>
      Navigator.pushReplacementNamed(this, routeName, arguments: arguments);

  void get pop => Navigator.pop(this);

  ARG? getArg<ARG>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args is ARG) {
      return args;
    }
    return null;
  }
}
