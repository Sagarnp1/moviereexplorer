import 'package:hive/hive.dart';

import 'movie.dart';

part 'favorite_movie.g.dart';

@HiveType(typeId: 0)
class FavoriteMovie extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String posterPath;
  @HiveField(3)
  final String releaseDate;
  @HiveField(4)
  final double voteAverage;
  @HiveField(5)
  final DateTime timestamp;

  FavoriteMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.timestamp,
  });

  factory FavoriteMovie.fromMovie(Movie movie) {
    return FavoriteMovie(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      timestamp: DateTime.now(),
    );
  }

  String get fullPosterUrl => posterPath.isNotEmpty 
      ? 'https://image.tmdb.org/t/p/w500$posterPath' 
      : 'https://via.placeholder.com/500x750?text=No+Image';

  String get releaseYear => releaseDate.isNotEmpty 
      ? releaseDate.split('-')[0] 
      : 'Unknown';

  String get formattedRating => voteAverage.toStringAsFixed(1);
}