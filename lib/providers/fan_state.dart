import 'package:flutter/foundation.dart';

class FanState extends ChangeNotifier {
  bool _isFanOn = false;

  bool get isFanOn => _isFanOn;

  void setFanState(bool value) {
    _isFanOn = value;
    notifyListeners();
  }
}
