import 'package:hive_flutter/hive_flutter.dart';

class UserPreferencesService {
  static const String _boxName = 'user_preferences';
  static const String _genrePreferencesKey = 'genre_preferences';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  
  late Box _preferencesBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _preferencesBox = await Hive.openBox(_boxName);
    } else {
      _preferencesBox = Hive.box(_boxName);
    }
  }

  // Genre Preferences
  Future<void> saveGenrePreferences(List<int> genreIds) async {
    await _preferencesBox.put(_genrePreferencesKey, genreIds);
  }

  List<int> getGenrePreferences() {
    final preferences = _preferencesBox.get(_genrePreferencesKey);
    if (preferences is List) {
      return List<int>.from(preferences);
    }
    return [];
  }

  Future<void> addGenrePreference(int genreId) async {
    final currentPreferences = getGenrePreferences();
    if (!currentPreferences.contains(genreId)) {
      currentPreferences.add(genreId);
      await saveGenrePreferences(currentPreferences);
    }
  }

  Future<void> removeGenrePreference(int genreId) async {
    final currentPreferences = getGenrePreferences();
    currentPreferences.remove(genreId);
    await saveGenrePreferences(currentPreferences);
  }

  bool isGenrePreferred(int genreId) {
    return getGenrePreferences().contains(genreId);
  }


  Future<void> setOnboardingCompleted(bool completed) async {
    await _preferencesBox.put(_onboardingCompletedKey, completed);
  }

  bool isOnboardingCompleted() {
    return _preferencesBox.get(_onboardingCompletedKey, defaultValue: false);
  }


  Future<void> clearAllPreferences() async {
    await _preferencesBox.clear();
  }
}