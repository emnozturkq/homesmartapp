import 'package:flutter/foundation.dart';

class DoorState extends ChangeNotifier {
  bool _isKapiOpen = false;

  bool get isKapiOpen => _isKapiOpen;

  void setDoorState(bool value) {
    _isKapiOpen = value;
    notifyListeners();
  }
}
