import 'package:shared_preferences/shared_preferences.dart';
import 'package:piko/core/di/injections.dart';

class CacheHelper {
  static dynamic getData({required String key}) {
    final prefs = sl<SharedPreferences>();
    return prefs.get(key);
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    final prefs = sl<SharedPreferences>();

    if (value is String) return await prefs.setString(key, value);
    if (value is int) return await prefs.setInt(key, value);
    if (value is bool) return await prefs.setBool(key, value);
    if (value is double) return await prefs.setDouble(key, value);
    if (value is List<String>) return await prefs.setStringList(key, value);

    throw ArgumentError(
      'Unsupported type for SharedPreferences: ${value.runtimeType}',
    );
  }

  static Future<bool> removeData({required String key}) async {
    final prefs = sl<SharedPreferences>();
    return await prefs.remove(key);
  }
}
