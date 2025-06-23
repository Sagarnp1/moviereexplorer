import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '4d096804f90af981595049c870a27b2b';

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
}