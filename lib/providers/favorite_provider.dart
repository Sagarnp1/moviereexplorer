import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/favorite_movie.dart';
import '../services/hive_service.dart';

class FavoriteProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<FavoriteMovie> _favorites = [];

  List<FavoriteMovie> get favorites => _favorites;

  FavoriteProvider() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _hiveService.init();
    _favorites = _hiveService.getFavorites();
    notifyListeners();

    // Listen to changes
    _hiveService.watchFavorites().listen((favorites) {
      _favorites = favorites;
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await _hiveService.removeFavorite(movie.id);
    } else {
      await _hiveService.addFavorite(movie);
    }
    _favorites = _hiveService.getFavorites();
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _hiveService.isFavorite(movieId);
  }
}