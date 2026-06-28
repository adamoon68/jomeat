import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static String _normalizeRole(dynamic role) {
    final value = (role ?? 'student').toString().trim().toLowerCase();
    return value.isEmpty ? 'student' : value;
  }

  static Future<void> saveUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('user_id', int.parse(user['user_id'].toString()));
    await prefs.setString('name', user['name'] ?? '');
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('role', _normalizeRole(user['role']));
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return _normalizeRole(prefs.getString('role'));
  }

  static Future<bool> isAdmin() async {
    return (await getUserRole()) == 'admin';
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
