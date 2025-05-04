import 'package:flutter/material.dart';

extension IntExt on int {
  SizedBox get sizeWidth => SizedBox(width: toDouble());
  SizedBox get sizeHeight => SizedBox(height: toDouble());
}

extension DoubleExt on double {
  SizedBox get sizeWidth => SizedBox(width: this);
  SizedBox get sizeHeight => SizedBox(height: this);
}

extension BuildContextExt on BuildContext {
  FocusScopeNode get focus => FocusScope.of(this);
}
