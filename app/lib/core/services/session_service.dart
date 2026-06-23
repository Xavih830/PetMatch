import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  final SharedPreferences _prefs;

  SessionService(this._prefs);

  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserRole = 'userRole';

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  String? getUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  Future<bool> saveSession({
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserName, userName);
    await _prefs.setString(_keyUserRole, userRole);
    return true;
  }

  Future<bool> clearSession() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserRole);
    return true;
  }
}
