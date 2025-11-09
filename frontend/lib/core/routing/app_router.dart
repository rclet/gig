import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';
import '../token_store.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/jobs/screens/job_list_screen.dart';
import '../../features/jobs/screens/job_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/projects/screens/project_list_screen.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/screens/main_navigation_screen.dart';
import '../../shared/screens/animation_demo_screen.dart';
import '../../screens/animation_preview.dart';
import '../../screens/rclet_demo_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Animation Demo (for internal testing)
      GoRoute(
        path: '/demo',
        name: 'demo',
        builder: (context, state) => const AnimationDemoScreen(),
      ),

      // Animation Preview (unauthenticated access)
      GoRoute(
        path: '/animation-preview',
        name: 'animation-preview',
        builder: (context, state) => const AnimationPreviewScreen(),
      ),

      // Rclet Demo (unauthenticated access)
      GoRoute(
        path: '/rclet-demo',
        name: 'rclet-demo',
        builder: (context, state) => const RcletDemoScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/jobs',
            name: 'jobs',
            builder: (context, state) => const JobListScreen(),
            routes: [
              GoRoute(
                path: '/:jobId',
                name: 'job-detail',
                builder: (context, state) => JobDetailScreen(
                  jobId: state.pathParameters['jobId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectListScreen(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      // Use TokenStore for auth check
      final token = await TokenStore.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      final isOnboardingCompleted = StorageService.isOnboardingCompleted();

      if (state.matchedLocation == '/splash' || state.matchedLocation == '/check-auth') {
        if (!isOnboardingCompleted) return '/onboarding';
        if (!isLoggedIn) return '/login';
        return '/home';
      }

      // Public routes that don't require auth
      final publicRoutes = [
        '/login',
        '/register',
        '/onboarding',
        '/splash',
        '/animation-preview',
        '/rclet-demo',
        '/demo',
      ];

      final isPublicRoute = publicRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      // Redirect to login if not authenticated and trying to access private route
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Redirect to home if authenticated and trying to access auth screens
      if (isLoggedIn &&
          (state.matchedLocation.startsWith('/login') ||
           state.matchedLocation.startsWith('/register') ||
           state.matchedLocation.startsWith('/onboarding'))) {
        return '/home';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
