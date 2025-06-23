import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/genre_provider.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_shimmer.dart';

class GenreMoviesScreen extends StatefulWidget {
  final Genre genre;

  const GenreMoviesScreen({
    super.key,
    required this.genre,
  });

  @override
  State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GenreProvider>(context, listen: false)
          .loadMoviesForGenre(widget.genre.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: widget.genre.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.genre.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.genre.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.genre.color,
                      widget.genre.color.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Consumer<GenreProvider>(
            builder: (context, genreProvider, child) {
              if (genreProvider.isLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const MovieShimmer(),
                      childCount: 6,
                    ),
                  ),
                );
              }

              final movies = genreProvider.moviesByGenre[widget.genre.id] ?? [];

              if (movies.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.genre.icon,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${widget.genre.name.toLowerCase()} movies found',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => genreProvider.loadMoviesForGenre(widget.genre.id),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        movie: movie,
                        onTap: () => context.push('/movie/${movie.id}', extra: movie),
                      );
                    },
                    childCount: movies.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}