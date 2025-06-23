import 'package:flutter/material.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../services/user_preferences_service.dart';

class GenreProvider with ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();
  final UserPreferencesService _preferencesService = UserPreferencesService();

  List<Genre> _availableGenres = MovieGenres.allGenres;
  List<int> _selectedGenres = [];
  Map<int, List<Movie>> _moviesByGenre = {};
  List<Movie> _recommendedMovies = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Genre> get availableGenres => _availableGenres;
  List<int> get selectedGenres => _selectedGenres;
  List<Genre> get selectedGenreObjects => 
      _selectedGenres.map((id) => MovieGenres.getGenreById(id)).where((g) => g != null).cast<Genre>().toList();
  Map<int, List<Movie>> get moviesByGenre => _moviesByGenre;
  List<Movie> get recommendedMovies => _recommendedMovies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSelectedGenres => _selectedGenres.isNotEmpty;

  GenreProvider() {
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    await _preferencesService.init();
    _selectedGenres = _preferencesService.getGenrePreferences();
    if (_selectedGenres.isNotEmpty) {
      await loadRecommendedMovies();
    }
    notifyListeners();
  }

  // genre selevction
  Future<void> toggleGenre(int genreId) async {
    if (_selectedGenres.contains(genreId)) {
      _selectedGenres.remove(genreId);
      await _preferencesService.removeGenrePreference(genreId);
    } else {
      _selectedGenres.add(genreId);
      await _preferencesService.addGenrePreference(genreId);
    }
    
    await _savePreferences();
    await loadRecommendedMovies();
    notifyListeners();
  }

  // Set multiple genres at once
  Future<void> setSelectedGenres(List<int> genreIds) async {
    _selectedGenres = List.from(genreIds);
    await _savePreferences();
    await loadRecommendedMovies();
    notifyListeners();
  }

  // Check genere selection
  bool isGenreSelected(int genreId) {
    return _selectedGenres.contains(genreId);
  }

  // Load movies for a specific genre
  Future<void> loadMoviesForGenre(int genreId) async {
    if (_moviesByGenre.containsKey(genreId)) return; // Already loaded

    _setLoading(true);
    try {
      final movies = await _tmdbService.getMoviesByGenre(genreId);
      _moviesByGenre[genreId] = movies;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load recommended movies based on selected genres
  Future<void> loadRecommendedMovies() async {
    if (_selectedGenres.isEmpty) {
      _recommendedMovies = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _recommendedMovies = await _tmdbService.getRecommendedMovies(_selectedGenres);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _recommendedMovies = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Movie>> getMoviesForGenre(int genreId) async {
    if (!_moviesByGenre.containsKey(genreId)) {
      await loadMoviesForGenre(genreId);
    }
    return _moviesByGenre[genreId] ?? [];
  }

  // Load top rated movies for a genre
  Future<List<Movie>> getTopRatedMoviesForGenre(int genreId) async {
    try {
      return await _tmdbService.getTopRatedMoviesByGenre(genreId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }


  Genre? getGenreById(int id) {
    return MovieGenres.getGenreById(id);
  }

  List<Genre> getGenresForMovie(List<int> genreIds) {
    return MovieGenres.getGenresByIds(genreIds);
  }

  Future<void> clearPreferences() async {
    _selectedGenres.clear();
    _moviesByGenre.clear();
    _recommendedMovies.clear();
    await _preferencesService.clearAllPreferences();
    notifyListeners();
  }


  Future<void> refresh() async {
    _moviesByGenre.clear();
    await loadRecommendedMovies();
    notifyListeners();
  }


  Future<void> _savePreferences() async {
    await _preferencesService.saveGenrePreferences(_selectedGenres);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }


  List<Genre> getPopularGenres() {

    return [
      MovieGenres.getGenreById(28)!, // Action
      MovieGenres.getGenreById(35)!, // Comedy
      MovieGenres.getGenreById(18)!, // Drama
      MovieGenres.getGenreById(27)!, // Horror
      MovieGenres.getGenreById(10749)!, // Romance
      MovieGenres.getGenreById(53)!, // Thriller
    ];
  }


  Map<String, dynamic> getGenreStats() {
    return {
      'totalGenres': _availableGenres.length,
      'selectedGenres': _selectedGenres.length,
      'loadedGenres': _moviesByGenre.keys.length,
      'recommendedMovies': _recommendedMovies.length,
    };
  }
}