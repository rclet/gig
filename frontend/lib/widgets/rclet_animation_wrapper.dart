import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable animation wrapper for Rclet Gig Lottie animations
/// 
/// Provides centralized loading, error handling, and fallback support
/// for all animations in the Rclet Gig Lottie Pack v1.0
class RcletAnimationWrapper extends StatelessWidget {
  /// Name of the animation file (without .json extension)
  final String animationName;
  
  /// Fallback widget to display if animation fails to load
  final Widget fallback;
  
  /// Whether the animation should loop
  final bool loop;
  
  /// Fixed height for the animation
  final double? height;
  
  /// Fixed width for the animation
  final double? width;
  
  /// Animation controller for external control
  final AnimationController? controller;
  
  /// Callback when animation completes (only for non-looping animations)
  final VoidCallback? onComplete;
  
  /// Whether to show a subtle loading indicator while loading
  final bool showLoading;
  
  /// Custom fit for the animation
  final BoxFit fit;

  const RcletAnimationWrapper({
    super.key,
    required this.animationName,
    required this.fallback,
    this.loop = true,
    this.height,
    this.width,
    this.controller,
    this.onComplete,
    this.showLoading = true,
    this.fit = BoxFit.contain,
  });

  /// Factory constructor for loading spinner
  factory RcletAnimationWrapper.loadingSpinner({
    Key? key,
    double? size,
    VoidCallback? onComplete,
  }) {
    return RcletAnimationWrapper(
      key: key,
      animationName: 'gig_loading_spinner',
      loop: true,
      height: size ?? 40.w,
      width: size ?? 40.w,
      onComplete: onComplete,
      fallback: SizedBox(
        width: size ?? 40.w,
        height: size ?? 40.w,
        child: const CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }

  /// Factory constructor for success tick
  factory RcletAnimationWrapper.successTick({
    Key? key,
    double? size,
    VoidCallback? onComplete,
  }) {
    return RcletAnimationWrapper(
      key: key,
      animationName: 'booking_success_tick',
      loop: false,
      height: size ?? 80.w,
      width: size ?? 80.w,
      onComplete: onComplete,
      fallback: Icon(
        Icons.check_circle,
        color: Colors.green,
        size: size ?? 80.w,
      ),
    );
  }

  /// Factory constructor for error alert
  factory RcletAnimationWrapper.errorAlert({
    Key? key,
    double? size,
    VoidCallback? onComplete,
  }) {
    return RcletAnimationWrapper(
      key: key,
      animationName: 'error_red_alert',
      loop: false,
      height: size ?? 100.w,
      width: size ?? 100.w,
      onComplete: onComplete,
      fallback: Icon(
        Icons.error,
        color: Colors.red,
        size: size ?? 100.w,
      ),
    );
  }

  /// Factory constructor for empty state
  factory RcletAnimationWrapper.emptyState({
    Key? key,
    double? size,
    VoidCallback? onComplete,
  }) {
    return RcletAnimationWrapper(
      key: key,
      animationName: 'no_gigs_empty',
      loop: false,
      height: size ?? 120.w,
      width: size ?? 120.w,
      onComplete: onComplete,
      fallback: Icon(
        Icons.folder_open,
        color: Colors.grey,
        size: size ?? 120.w,
      ),
    );
  }

  /// Factory constructor for onboarding handshake
  factory RcletAnimationWrapper.onboardingHandshake({
    Key? key,
    double? size,
    VoidCallback? onComplete,
  }) {
    return RcletAnimationWrapper(
      key: key,
      animationName: 'onboarding_handshake',
      loop: true,
      height: size ?? 150.w,
      width: size ?? 150.w,
      onComplete: onComplete,
      fallback: Icon(
        Icons.handshake,
        color: Colors.blue,
        size: size ?? 150.w,
      ),
    );
  }

  /// Factory constructor for tap ripple
  factory RcletAnimationWrapper.tapRipple({
    Key? key,
    double? size,
    VoidCallback? onComplete,
    AnimationController? controller,
  }) {
    return RcletAnimationWrapper(
      key: key,
      animationName: 'tap_ripple_micro',
      loop: false,
      height: size ?? 60.w,
      width: size ?? 60.w,
      controller: controller,
      onComplete: onComplete,
      showLoading: false,
      fallback: const SizedBox.shrink(),
    );
  }

  String get _assetPath => 'assets/animations/$animationName.json';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: FutureBuilder<bool>(
        future: _checkAssetExists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return showLoading
                ? Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : fallback;
          }

          if (snapshot.hasError || snapshot.data != true) {
            return fallback;
          }

          return _buildLottieAnimation();
        },
      ),
    );
  }

  Widget _buildLottieAnimation() {
    if (controller != null) {
      return Lottie.asset(
        _assetPath,
        controller: controller,
        repeat: loop,
        fit: fit,
        onLoaded: (composition) {
          if (onComplete != null && !loop) {
            controller?.forward().then((_) => onComplete?.call());
          }
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Lottie animation error: $error');
          return fallback;
        },
      );
    }

    return Lottie.asset(
      _assetPath,
      repeat: loop,
      fit: fit,
      onLoaded: (composition) {
        if (onComplete != null && !loop) {
          // For animations without controller, we estimate completion time
          Future.delayed(
            Duration(milliseconds: (composition.duration.inMilliseconds * 0.9).round()),
            () => onComplete?.call(),
          );
        }
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Lottie animation error: $error');
        return fallback;
      },
    );
  }

  Future<bool> _checkAssetExists() async {
    try {
      // This is a simple check - in a real app you might want to
      // implement a more robust asset existence check
      await Future.delayed(const Duration(milliseconds: 100));
      return true; // Assume assets exist for placeholder implementation
    } catch (e) {
      return false;
    }
  }
}

/// Extension for easy access to common Rclet animations
extension RcletAnimationShortcuts on Widget {
  /// Wrap widget with a loading spinner overlay
  Widget withLoadingSpinner({
    bool isLoading = false,
    double? size,
    Color? backgroundColor,
  }) {
    if (!isLoading) return this;
    
    return Stack(
      children: [
        this,
        Positioned.fill(
          child: Container(
            color: backgroundColor ?? Colors.black26,
            child: Center(
              child: RcletAnimationWrapper.loadingSpinner(size: size),
            ),
          ),
        ),
      ],
    );
  }
}