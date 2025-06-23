import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieProvider with ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();
  
  List<Movie> _searchResults = [];
  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = '';

  List<Movie> get searchResults => _searchResults;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  MovieProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _popularMovies = await _tmdbService.getPopularMovies();
      _trendingMovies = await _tmdbService.getTrendingMovies();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    _currentQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _currentQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}