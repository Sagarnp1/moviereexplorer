import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/genre.dart';

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '//api key removed';

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/movie?query=$query&api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to TMDB API: $e');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get popular movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to TMDB API: $e');
    }
  }

  Future<List<Movie>> getTrendingMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/day?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get trending movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to TMDB API: $e');
    }
  }

  // movies by genre
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/discover/movie?with_genres=$genreId&api_key=$_apiKey&page=$page&sort_by=popularity.desc'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get movies by genre: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to TMDB API: $e');
    }
  }

  //  recommended movies based on multiple genres
  Future<List<Movie>> getRecommendedMovies(List<int> genreIds, {int page = 1}) async {
    if (genreIds.isEmpty) {
      return getPopularMovies(); // Fallback to popular movies
    }

    try {
      final genreString = genreIds.join(',');
      final response = await http.get(
        Uri.parse('$_baseUrl/discover/movie?with_genres=$genreString&api_key=$_apiKey&page=$page&sort_by=vote_average.desc&vote_count.gte=100'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get recommended movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to TMDB API: $e');
    }
  }

  // top rated movies by genre
  Future<List<Movie>> getTopRatedMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/discover/movie?with_genres=$genreId&api_key=$_apiKey&page=$page&sort_by=vote_average.desc&vote_count.gte=500'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get top rated movies by genre: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to TMDB API: $e');
    }
  }

  // all available genres from API(TMDB)
  Future<List<Genre>> getGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> genres = data['genres'] ?? [];
        return genres.map((json) => Genre.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get genres: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to TMDB API: $e');
    }
  }
}
