import 'package:flutter/material.dart';

class Genre {
  final int id;
  final String name;
  final IconData icon;
  final Color color;

  Genre({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
      icon: _getIconForGenre(json['name']),
      color: _getColorForGenre(json['name']),
    );
  }

  static IconData _getIconForGenre(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'action':
        return Icons.local_fire_department;
      case 'adventure':
        return Icons.explore;
      case 'animation':
        return Icons.animation;
      case 'comedy':
        return Icons.sentiment_very_satisfied;
      case 'crime':
        return Icons.gavel;
      case 'documentary':
        return Icons.movie_filter;
      case 'drama':
        return Icons.theater_comedy;
      case 'family':
        return Icons.family_restroom;
      case 'fantasy':
        return Icons.auto_fix_high;
      case 'history':
        return Icons.history_edu;
      case 'horror':
        return Icons.nightlight;
      case 'music':
        return Icons.music_note;
      case 'mystery':
        return Icons.search;
      case 'romance':
        return Icons.favorite;
      case 'science fiction':
        return Icons.rocket_launch;
      case 'tv movie':
        return Icons.tv;
      case 'thriller':
        return Icons.flash_on;
      case 'war':
        return Icons.military_tech;
      case 'western':
        return Icons.landscape;
      default:
        return Icons.movie;
    }
  }

  static Color _getColorForGenre(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'action':
        return Colors.red;
      case 'adventure':
        return Colors.green;
      case 'animation':
        return Colors.purple;
      case 'comedy':
        return Colors.yellow;
      case 'crime':
        return Colors.grey;
      case 'documentary':
        return Colors.brown;
      case 'drama':
        return Colors.blue;
      case 'family':
        return Colors.pink;
      case 'fantasy':
        return Colors.deepPurple;
      case 'history':
        return Colors.amber;
      case 'horror':
        return Colors.black;
      case 'music':
        return Colors.cyan;
      case 'mystery':
        return Colors.indigo;
      case 'romance':
        return Colors.pinkAccent;
      case 'science fiction':
        return Colors.teal;
      case 'tv movie':
        return Colors.orange;
      case 'thriller':
        return Colors.redAccent;
      case 'war':
        return Colors.blueGrey;
      case 'western':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
}

// Predefined genres with TMDB IDs
class MovieGenres {
  static final List<Genre> allGenres = [
    Genre(id: 28, name: 'Action', icon: Icons.local_fire_department, color: Colors.red),
    Genre(id: 12, name: 'Adventure', icon: Icons.explore, color: Colors.green),
    Genre(id: 16, name: 'Animation', icon: Icons.animation, color: Colors.purple),
    Genre(id: 35, name: 'Comedy', icon: Icons.sentiment_very_satisfied, color: Colors.yellow),
    Genre(id: 80, name: 'Crime', icon: Icons.gavel, color: Colors.grey),
    Genre(id: 99, name: 'Documentary', icon: Icons.movie_filter, color: Colors.brown),
    Genre(id: 18, name: 'Drama', icon: Icons.theater_comedy, color: Colors.blue),
    Genre(id: 10751, name: 'Family', icon: Icons.family_restroom, color: Colors.pink),
    Genre(id: 14, name: 'Fantasy', icon: Icons.auto_fix_high, color: Colors.deepPurple),
    Genre(id: 36, name: 'History', icon: Icons.history_edu, color: Colors.amber),
    Genre(id: 27, name: 'Horror', icon: Icons.nightlight, color: Colors.black),
    Genre(id: 10402, name: 'Music', icon: Icons.music_note, color: Colors.cyan),
    Genre(id: 9648, name: 'Mystery', icon: Icons.search, color: Colors.indigo),
    Genre(id: 10749, name: 'Romance', icon: Icons.favorite, color: Colors.pinkAccent),
    Genre(id: 878, name: 'Science Fiction', icon: Icons.rocket_launch, color: Colors.teal),
    Genre(id: 10770, name: 'TV Movie', icon: Icons.tv, color: Colors.orange),
    Genre(id: 53, name: 'Thriller', icon: Icons.flash_on, color: Colors.redAccent),
    Genre(id: 10752, name: 'War', icon: Icons.military_tech, color: Colors.blueGrey),
    Genre(id: 37, name: 'Western', icon: Icons.landscape, color: Colors.deepOrange),
  ];

  static Genre? getGenreById(int id) {
    try {
      return allGenres.firstWhere((genre) => genre.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Genre> getGenresByIds(List<int> ids) {
    return ids.map((id) => getGenreById(id)).where((genre) => genre != null).cast<Genre>().toList();
  }

  static Genre getGenreByName(String name) {
    try {
      return allGenres.firstWhere((genre) => genre.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return Genre(id: 0, name: name, icon: Icons.movie, color: Colors.grey);
    }
  }
}