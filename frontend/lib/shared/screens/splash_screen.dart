import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/components/rclet_guardian_mascot.dart';
import '../../core/token_store.dart';
import '../../features/auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      await _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    try {
      // Check if user has a token
      final hasToken = await TokenStore.hasToken();
      
      if (!hasToken) {
        // No token, go to login
        if (mounted) context.go('/login');
        return;
      }

      // Try to get current user
      final success = await ref.read(authProvider.notifier).getCurrentUser();
      
      if (mounted) {
        if (success) {
          // Auth successful, go to home
          context.go('/home');
        } else {
          // Auth failed, go to login
          context.go('/login');
        }
      }
    } catch (e) {
      // On error, go to login
      if (mounted) context.go('/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeController, _scaleController]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rclet Guardian Mascot
                      RcletGuardianMascot.buildAnimatedMascot(
                        size: MascotSize.large,
                        state: MascotState.active,
                        showMessage: false,
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'Gig Marketplace',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'gig.com.bd',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 48.h),

                      // ✅ Rclet Gig Loading Animation
                      GigAnimationWrapper.loadingSpinner(
                        size: 60.w,
                        color: Colors.white,
                      ),

                      SizedBox(height: 16.h),
                      Text(
                        'Rclet Guardian is initializing...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // ✅ Subtle red dot indicator for v1.0
                      RedDotAnimationWrapper(
                        showRedDot: true,
                        dotSize: 6.0,
                        child: Text(
                          'v1.0 Lottie Pack',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
