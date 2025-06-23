import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/genre_provider.dart';
import '../models/genre.dart';

class GenreSelectionScreen extends StatefulWidget {
  final bool isOnboarding;

  const GenreSelectionScreen({
    super.key,
    this.isOnboarding = false,
  });

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      if (!widget.isOnboarding)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.movie_filter,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.isOnboarding ? 'Choose Your Favorite Genres' : 'Manage Your Preferences',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isOnboarding
                            ? 'Select genres you love to get personalized recommendations'
                            : 'Update your genre preferences to improve recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Genre Grid
              Expanded(
                child: Consumer<GenreProvider>(
                  builder: (context, genreProvider, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: genreProvider.availableGenres.length,
                          itemBuilder: (context, index) {
                            final genre = genreProvider.availableGenres[index];
                            final isSelected = genreProvider.isGenreSelected(genre.id);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: GenreCard(
                                genre: genre,
                                isSelected: isSelected,
                                onTap: () => genreProvider.toggleGenre(genre.id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Action
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<GenreProvider>(
                  builder: (context, genreProvider, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          if (genreProvider.hasSelectedGenres)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${genreProvider.selectedGenres.length} genres selected',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: genreProvider.hasSelectedGenres
                                  ? () => _handleContinue(context, genreProvider)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: genreProvider.hasSelectedGenres
                                    ? Colors.red
                                    : Colors.grey[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                widget.isOnboarding ? 'Continue' : 'Save Preferences',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (widget.isOnboarding)
                            TextButton(
                              onPressed: () => context.go('/'),
                              child: Text(
                                'Skip for now',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context, GenreProvider genreProvider) {
    if (widget.isOnboarding) {
      context.go('/');
    } else {
      context.pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preferences saved! You\'ll see personalized recommendations.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class GenreCard extends StatelessWidget {
  final Genre genre;
  final bool isSelected;
  final VoidCallback onTap;

  const GenreCard({
    super.key,
    required this.genre,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [genre.color.withOpacity(0.8), genre.color],
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFF2A2A2A),
                    const Color(0xFF1A1A1A),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? genre.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? genre.color.withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                genre.icon,
                color: isSelected ? Colors.white : genre.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  genre.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}