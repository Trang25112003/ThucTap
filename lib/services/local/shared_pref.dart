import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/job_model.dart';
import '../../models/user_model.dart';

class SharedPrefs {
  static const String checkAccess = 'checkAccess';
  static const String userKey = 'user';
  static const String _localeKey = 'app_locale';
  static const String _favoriteKey = 'favorite_jobs';

  static late SharedPreferences _prefs;

  // Khởi tạo SharedPreferences
  static Future<void> initialise() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getter để lấy instance
  static SharedPreferences get instance => _prefs;

  // Lưu ngôn ngữ
  static Future<bool> saveLocale(String languageCode) async {
    return _prefs.setString(_localeKey, languageCode);
  }

  // Lấy ngôn ngữ đã lưu
  static Future<String?> getLocale() async {
    return _prefs.getString(_localeKey);
  }

  static bool get isAccessed => _prefs.getBool(checkAccess) ?? false;

  static set isAccessed(bool value) => _prefs.setBool(checkAccess, value);

  static bool get isLogin {
    String? data = _prefs.getString(userKey);
    return data != null;
  }

  static UserModel? get user {
    String? data = _prefs.getString(userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  static set user(UserModel? user) {
    _prefs.setString(userKey, jsonEncode(user?.toJson()));
  }

  static void removeSession() {
    _prefs.remove(userKey);
  }

  // Lưu danh sách công việc yêu thích
  static Future<void> saveFavoriteJobs(List<Job> jobs) async {
    try {
      final jobStrings = jobs.map((e) => json.encode(e.toJson())).toList();
      await _prefs.setStringList(_favoriteKey, jobStrings);
    } catch (e) {
      print("Error saving favorite jobs: $e");
    }
  }

  // Lấy danh sách công việc yêu thích
  static List<Job> getFavoriteJobs() {
    final jobStrings = _prefs.getStringList(_favoriteKey);
    if (jobStrings == null) return [];
    return jobStrings.map((e) => Job.fromJson(json.decode(e))).toList();
  }

  // Thêm công việc vào danh sách yêu thích
  static Future<void> addFavorite(Job job) async {
    final favorites = getFavoriteJobs();
    if (!favorites.any((j) => j.id == job.id)) {
      favorites.add(job);
      await saveFavoriteJobs(favorites);
    }
  }

  // Xóa công việc khỏi danh sách yêu thích
  static Future<void> removeFavorite(Job job) async {
    final favorites = getFavoriteJobs();
    favorites.removeWhere((j) => j.id == job.id);
    await saveFavoriteJobs(favorites);
  }

  // Kiểm tra công việc có trong danh sách yêu thích không
  static bool isFavorite(Job job) {
    final favorites = getFavoriteJobs();
    return favorites.any((j) => j.id == job.id);
  }
}
