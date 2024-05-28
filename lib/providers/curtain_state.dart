import 'package:flutter/foundation.dart';

class CurtainState extends ChangeNotifier {
  bool _isCurtainOpen = false;

  bool get isCurtainOpen => _isCurtainOpen;

  void setCurtainState(bool value) {
    _isCurtainOpen = value;
    notifyListeners();
  }
}
