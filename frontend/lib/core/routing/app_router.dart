import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';
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
import '../../screens/animation_preview.dart';
import '../../screens/rclet_demo_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication
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

      // Animation Preview (accessible without authentication for development)
      GoRoute(
        path: '/animation-preview',
        name: 'animation-preview',
        builder: (context, state) => const AnimationPreviewScreen(),
      ),

      // Rclet Demo (accessible without authentication for development)
      GoRoute(
        path: '/rclet-demo',
        name: 'rclet-demo',
        builder: (context, state) => const RcletDemoScreen(),
      ),

      // Main Navigation Shell
      ShellRoute(
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Jobs
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

          // Projects
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectListScreen(),
          ),

          // Chat
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatListScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = StorageService.getAuthToken() != null;
      final isOnboardingCompleted = StorageService.isOnboardingCompleted();
      
      // Handle splash screen redirect and check-auth route
      if (state.matchedLocation == '/splash' || state.matchedLocation == '/check-auth') {
        if (!isOnboardingCompleted) {
          return '/onboarding';
        } else if (!isLoggedIn) {
          return '/login';
        } else {
          return '/home';
        }
      }

      // Redirect to login if not authenticated
      if (!isLoggedIn && 
          !state.matchedLocation.startsWith('/login') && 
          !state.matchedLocation.startsWith('/register') &&
          !state.matchedLocation.startsWith('/onboarding') &&
          !state.matchedLocation.startsWith('/splash') &&
          !state.matchedLocation.startsWith('/animation-preview') &&
          !state.matchedLocation.startsWith('/rclet-demo')) {
        return '/login';
      }

      // Redirect to home if authenticated and trying to access auth pages
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