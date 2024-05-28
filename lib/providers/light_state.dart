import 'package:flutter/foundation.dart';

class LightState extends ChangeNotifier {
  bool _isLightOpen = false;

  bool get isLightOpen => _isLightOpen;

  void setLightState(bool value) {
    _isLightOpen = value;
    notifyListeners();
  }
}
