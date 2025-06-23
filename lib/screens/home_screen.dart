import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import '../providers/movie_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/genre_provider.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final genreProvider = Provider.of<GenreProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Movie Explorer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF0F0F0F),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () => context.push('/genre-selection'),
              ),
            ],
          ),
          
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.red),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              movieProvider.clearSearch();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (query) {
                    movieProvider.searchMovies(query);
                  },
                ),
              ),
            ),
          ),

          // Genre 
          if (genreProvider.hasSelectedGenres)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Genres',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/genre-selection'),
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: genreProvider.selectedGenreObjects.length,
                      itemBuilder: (context, index) {
                        final genre = genreProvider.selectedGenreObjects[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GenreChip(
                            genre: genre,
                            onTap: () => context.push('/genre-movies', extra: genre),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          
          if (movieProvider.currentQuery.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Search Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildMovieGrid(movieProvider.searchResults, movieProvider.isLoading),
          ] else ...[
            
            if (genreProvider.hasSelectedGenres && genreProvider.recommendedMovies.isNotEmpty)
              _buildMovieSection('Recommended for You', genreProvider.recommendedMovies, genreProvider.isLoading),
            
            
            _buildMovieSection('Trending Now', movieProvider.trendingMovies, movieProvider.isLoading),
            _buildMovieSection('Popular Movies', movieProvider.popularMovies, movieProvider.isLoading),
            
            
            ...genreProvider.selectedGenreObjects.take(3).map((genre) {
              return FutureBuilder<List<Movie>>(
                future: genreProvider.getMoviesForGenre(genre.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return _buildMovieSection(
                      'Best ${genre.name} Movies',
                      snapshot.data!,
                      false,
                      genre: genre,
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMovieSection(String title, List<Movie> movies, bool isLoading, {Genre? genre}) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (genre != null) ...[
                      Icon(genre.icon, color: genre.color, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (genre != null)
                  TextButton(
                    onPressed: () => context.push('/genre-movies', extra: genre),
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: isLoading
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) => const MovieShimmer(),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        movie: movie,
                        onTap: () => context.push('/movie/${movie.id}', extra: movie),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies, bool isLoading) {
    if (isLoading) {
      return SliverGrid(
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
  }
}

class GenreChip extends StatelessWidget {
  final Genre genre;
  final VoidCallback onTap;

  const GenreChip({
    super.key,
    required this.genre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: genre.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: genre.color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(genre.icon, color: genre.color, size: 16),
            const SizedBox(width: 6),
            Text(
              genre.name,
              style: TextStyle(
                color: genre.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
