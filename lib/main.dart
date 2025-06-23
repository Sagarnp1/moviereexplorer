import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'providers/movie_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/genre_provider.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/genre_selection_screen.dart';
import 'screens/genre_movies_screen.dart';
import 'models/movie.dart';
import 'models/genre.dart';
import 'models/favorite_movie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  //  Hive
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteMovieAdapter());
  
  await Hive.openBox<FavoriteMovie>('favorites');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp.router(
          title: 'Movie Explorer',
          theme: _buildTheme(),
          routerConfig: _createRouter(authProvider),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0F0F),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Colors.red,
        secondary: Colors.redAccent,
        surface: Color(0xFF1A1A1A),
        background: Color(0xFF0F0F0F),
      ),
      useMaterial3: true,
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.uri.toString().startsWith('/signin') ||
            state.uri.toString().startsWith('/signup') ||
            state.uri.toString().startsWith('/forgot-password');


        if (!isAuthenticated && !isAuthRoute) {
          return '/signin';
        }


        if (isAuthenticated && isAuthRoute) {
          return '/';
        }

        return null;
      },
      routes: <RouteBase>[
        // Auth r
        GoRoute(
          path: '/signin',
          builder: (BuildContext context, GoRouterState state) {
            return const SignInScreen();
          },
        ),
        GoRoute(
          path: '/signup',
          builder: (BuildContext context, GoRouterState state) {
            return const SignUpScreen();
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordScreen();
          },
        ),


        GoRoute(
          path: '/genre-selection',
          builder: (BuildContext context, GoRouterState state) {
            return const GenreSelectionScreen();
          },
        ),
        GoRoute(
          path: '/genre-movies',
          builder: (BuildContext context, GoRouterState state) {

            final genre = state.extra is Genre ? state.extra as Genre : null;
            if (genre == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Genre not found')),
              );
            }
            return GenreMoviesScreen(genre: genre);
          },
        ),


        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return MainScaffold(child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen();
              },
            ),
            GoRoute(
              path: '/favorites',
              builder: (BuildContext context, GoRouterState state) {
                return const FavoritesScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: '/movie/:id',
          builder: (BuildContext context, GoRouterState state) {

            final movie = state.extra is Movie ? state.extra as Movie : null;
            if (movie == null) {
              return const Scaffold(
                body: Center(child: Text('Error: Movie not found')),
              );
            }
            return MovieDetailScreen(movie: movie);
          },
        ),
      ],
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/favorites');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: GoRouterState.of(context).uri.toString() == '/',
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && GoRouterState.of(context).uri.toString() != '/') {
          context.go('/');
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        drawer: _buildDrawer(context),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final genreProvider = Provider.of<GenreProvider>(context);
    final user = authProvider.user;

    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.redAccent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.red),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? user?.email ?? 'Movie Explorer User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.white),
            title: const Text('Favorites', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.go('/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.movie_filter, color: Colors.white),
            title: const Text('Genre Preferences', style: TextStyle(color: Colors.white)),
            trailing: genreProvider.hasSelectedGenres
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${genreProvider.selectedGenres.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
                : null,
            onTap: () {
              Navigator.pop(context);
              context.push('/genre-movies'); 
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final shouldLogout = await _showSignOutDialog(context);
              if (shouldLogout == true) {
                await authProvider.signOut();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to sign out of Movie Explorer?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
