import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = 'Rizky';
  String _email = 'rizky@email.com';
  bool _notifications = true;
  bool _hideBalance = false;

  String get name => _name;
  String get email => _email;
  bool get notifications => _notifications;
  bool get hideBalance => _hideBalance;

  void updateProfile({required String name, required String email}) {
    _name = name;
    _email = email;
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notifications = value;
    notifyListeners();
  }

  void setHideBalance(bool value) {
    _hideBalance = value;
    notifyListeners();
  }
}
