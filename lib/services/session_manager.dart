import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._internal();
  static final SessionManager instance = SessionManager._internal();

  static const _kTokenKey = 'auth_token';
  static const _kUserNameKey = 'user_name';

  // Keep this in sync with RoomsScreen
  static const String _roomsKeyPrefix = 'rooms_list_v1_';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserNameKey);
  }

  /// Logs out user: clears token + username AND clears that user's rooms cache.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    // Read username BEFORE removing it, so we can clear user-specific rooms.
    final username = prefs.getString(_kUserNameKey);

    if (username != null && username.isNotEmpty) {
      await prefs.remove('$_roomsKeyPrefix$username');
    }

    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserNameKey);
  }
}
