import 'package:hive_flutter/hive_flutter.dart';
import '../models/movie.dart';
import '../models/favorite_movie.dart';

class HiveService {
  late Box<FavoriteMovie> _favoritesBox;
  static const String _boxName = 'favorites';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _favoritesBox = await Hive.openBox<FavoriteMovie>(_boxName);
    } else {
      _favoritesBox = Hive.box<FavoriteMovie>(_boxName);
    }
  }

  Future<void> addFavorite(Movie movie) async {
    final favorite = FavoriteMovie.fromMovie(movie);
    await _favoritesBox.put(movie.id, favorite);
  }

  Future<void> removeFavorite(int movieId) async {
    await _favoritesBox.delete(movieId);
  }

  bool isFavorite(int movieId) {
    return _favoritesBox.containsKey(movieId);
  }

  List<FavoriteMovie> getFavorites() {
    return _favoritesBox.values.toList();
  }

  Stream<List<FavoriteMovie>> watchFavorites() {
    return _favoritesBox.watch().map((event) => _favoritesBox.values.toList());
  }
}