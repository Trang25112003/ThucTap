import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStore extends ChangeNotifier {
  Set<String> _favoriteJobs = {};
  
  UserStore() {
    _loadFavorites();
  }
  
  bool isFavorite(String jobId) {
    return _favoriteJobs.contains(jobId);
  }
  
  void toggleFavoriteJob(String jobId) {
    if (_favoriteJobs.contains(jobId)) {
      _favoriteJobs.remove(jobId);
    } else {
      _favoriteJobs.add(jobId);
    }
    _saveFavorites();
    notifyListeners();
  }
  
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_jobs') ?? [];
    _favoriteJobs = Set<String>.from(favorites);
    notifyListeners();
  }
  
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_jobs', _favoriteJobs.toList());
  }
}