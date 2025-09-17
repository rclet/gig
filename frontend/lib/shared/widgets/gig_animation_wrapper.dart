import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable animation wrapper for Lottie animations in the Gig Marketplace
/// Provides consistent styling, error handling, and loading states
class GigAnimationWrapper extends StatelessWidget {
  final String animationPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool repeat;
  final bool reverse;
  final bool animate;
  final VoidCallback? onAnimationFinished;
  final Widget? fallbackWidget;
  final Color? color;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;

  const GigAnimationWrapper({
    super.key,
    required this.animationPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.animate = true,
    this.onAnimationFinished,
    this.fallbackWidget,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.padding,
    this.margin,
    this.decoration,
  });

  /// Factory constructor for loading spinner
  factory GigAnimationWrapper.loadingSpinner({
    double? size,
    Color? color,
  }) {
    return GigAnimationWrapper(
      animationPath: 'assets/animations/gig_loading_spinner.json',
      width: size ?? 40.w,
      height: size ?? 40.w,
      color: color,
      repeat: true,
      animate: true,
    );
  }

  /// Factory constructor for empty state
  factory GigAnimationWrapper.emptyState({
    double? width,
    double? height,
  }) {
    return GigAnimationWrapper(
      animationPath: 'assets/animations/no_gigs_empty.json',
      width: width ?? 120.w,
      height: height ?? 120.h,
      repeat: false,
      animate: true,
    );
  }

  /// Factory constructor for success animation
  factory GigAnimationWrapper.success({
    double? size,
    VoidCallback? onFinished,
  }) {
    return GigAnimationWrapper(
      animationPath: 'assets/animations/booking_success_tick.json',
      width: size ?? 80.w,
      height: size ?? 80.h,
      repeat: false,
      animate: true,
      onAnimationFinished: onFinished,
    );
  }

  /// Factory constructor for error animation
  factory GigAnimationWrapper.error({
    double? size,
    Color? color,
  }) {
    return GigAnimationWrapper(
      animationPath: 'assets/animations/error_red_alert.json',
      width: size ?? 60.w,
      height: size ?? 60.h,
      color: color ?? Colors.red,
      repeat: true,
      animate: true,
    );
  }

  /// Factory constructor for onboarding handshake
  factory GigAnimationWrapper.onboarding({
    double? width,
    double? height,
  }) {
    return GigAnimationWrapper(
      animationPath: 'assets/animations/onboarding_handshake.json',
      width: width ?? 200.w,
      height: height ?? 120.h,
      repeat: true,
      animate: true,
    );
  }

  /// Factory constructor for tap ripple
  factory GigAnimationWrapper.tapRipple({
    double? size,
    Color? color,
  }) {
    return GigAnimationWrapper(
      animationPath: 'assets/animations/tap_ripple_micro.json',
      width: size ?? 30.w,
      height: size ?? 30.h,
      color: color,
      repeat: false,
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget animation = Lottie.asset(
      animationPath,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      reverse: reverse,
      animate: animate,
      onLoaded: (composition) {
        if (!repeat && onAnimationFinished != null) {
          Future.delayed(composition.duration, onAnimationFinished);
        }
      },
      errorBuilder: (context, error, stackTrace) {
        return fallbackWidget ??
            Container(
              width: width ?? 40.w,
              height: height ?? 40.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.animation,
                size: (width ?? 40.w) / 2,
                color: Colors.grey.shade400,
              ),
            );
      },
      frameRate: FrameRate.max,
    );

    // Apply color filtering if specified
    if (color != null) {
      animation = ColorFiltered(
        colorFilter: ColorFilter.mode(
          color!,
          colorBlendMode ?? BlendMode.srcATop,
        ),
        child: animation,
      );
    }

    // Apply alignment
    animation = Align(
      alignment: alignment,
      child: animation,
    );

    // Apply padding if specified
    if (padding != null) {
      animation = Padding(
        padding: padding!,
        child: animation,
      );
    }

    // Apply decoration and margin if specified
    if (decoration != null || margin != null) {
      animation = Container(
        margin: margin,
        decoration: decoration,
        child: animation,
      );
    }

    return animation;
  }
}

/// Specialized animation wrapper for red-dot motif effects
class RedDotAnimationWrapper extends StatelessWidget {
  final Widget child;
  final bool showRedDot;
  final double dotSize;
  final Offset? dotOffset;
  final Color dotColor;

  const RedDotAnimationWrapper({
    super.key,
    required this.child,
    this.showRedDot = false,
    this.dotSize = 8.0,
    this.dotOffset,
    this.dotColor = const Color(0xFFE53E3E), // Bangladesh flag inspired red
  });

  @override
  Widget build(BuildContext context) {
    if (!showRedDot) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: dotOffset?.dy ?? -2.h,
          right: dotOffset?.dx ?? -2.w,
          child: Container(
            width: dotSize.w,
            height: dotSize.h,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: dotColor.withOpacity(0.3),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}