import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// Enumeration of available Rclet animations
enum RcletAnimationType {
  gigSuccess,
  proposalSent,
  loadingSpinner,
  errorRed,
  emptyState,
  chatbotAgent,
}

/// Extension to get the asset path for each animation type
extension RcletAnimationTypeExtension on RcletAnimationType {
  String get assetPath {
    switch (this) {
      case RcletAnimationType.gigSuccess:
        return 'assets/animations/gig_success.json';
      case RcletAnimationType.proposalSent:
        return 'assets/animations/proposal_sent.json';
      case RcletAnimationType.loadingSpinner:
        return 'assets/animations/loading_spinner.json';
      case RcletAnimationType.errorRed:
        return 'assets/animations/error_red.json';
      case RcletAnimationType.emptyState:
        return 'assets/animations/empty_state.json';
      case RcletAnimationType.chatbotAgent:
        return 'assets/animations/chatbot_agent.json';
    }
  }

  /// Get default dimensions for each animation type
  Size get defaultSize {
    switch (this) {
      case RcletAnimationType.gigSuccess:
        return Size(120.w, 120.w);
      case RcletAnimationType.proposalSent:
        return Size(100.w, 100.w);
      case RcletAnimationType.loadingSpinner:
        return Size(60.w, 60.w);
      case RcletAnimationType.errorRed:
        return Size(80.w, 80.w);
      case RcletAnimationType.emptyState:
        return Size(200.w, 150.w);
      case RcletAnimationType.chatbotAgent:
        return Size(150.w, 150.w);
    }
  }

  /// Determine if animation should loop by default
  bool get shouldLoop {
    switch (this) {
      case RcletAnimationType.gigSuccess:
      case RcletAnimationType.proposalSent:
      case RcletAnimationType.errorRed:
        return false; // One-time success/error animations
      case RcletAnimationType.loadingSpinner:
      case RcletAnimationType.emptyState:
      case RcletAnimationType.chatbotAgent:
        return true; // Continuous animations
    }
  }

  /// Determine if animation should autoplay by default
  bool get shouldAutoPlay {
    switch (this) {
      case RcletAnimationType.loadingSpinner:
      case RcletAnimationType.emptyState:
      case RcletAnimationType.chatbotAgent:
        return true; // Always playing animations
      case RcletAnimationType.gigSuccess:
      case RcletAnimationType.proposalSent:
      case RcletAnimationType.errorRed:
        return true; // Play immediately when shown
    }
  }
}

/// A reusable widget for displaying Rclet Corporation branded Lottie animations
/// with built-in responsiveness, loading states, and error handling.
class RcletAnimation extends StatefulWidget {
  /// Creates an RcletAnimation widget.
  const RcletAnimation({
    super.key,
    required this.animationType,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat,
    this.reverse = false,
    this.animate,
    this.frameRate = FrameRate.max,
    this.onLoaded,
    this.controller,
    this.delegates,
    this.options,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.errorBuilder,
    this.loadingBuilder,
  });

  /// The type of animation to display
  final RcletAnimationType animationType;

  /// Width of the animation widget. Defaults to type-specific size.
  final double? width;

  /// Height of the animation widget. Defaults to type-specific size.
  final double? height;

  /// How the animation should be fitted inside the widget bounds
  final BoxFit fit;

  /// Whether the animation should repeat. Defaults to type-specific behavior.
  final bool? repeat;

  /// Whether to reverse the animation
  final bool reverse;

  /// Whether the animation should auto-play. Defaults to type-specific behavior.
  final bool? animate;

  /// Frame rate for the animation
  final FrameRate frameRate;

  /// Callback when the animation is loaded
  final LottieDelegates? delegates;

  /// Lottie options for customization
  final LottieOptions? options;

  /// Alignment of the animation within its bounds
  final AlignmentGeometry alignment;

  /// Filter quality for the animation
  final FilterQuality filterQuality;

  /// Callback when the animation composition is loaded
  final void Function(LottieComposition)? onLoaded;

  /// Animation controller for custom control
  final AnimationController? controller;

  /// Custom error widget builder
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  /// Custom loading widget builder  
  final Widget Function(BuildContext)? loadingBuilder;

  @override
  State<RcletAnimation> createState() => _RcletAnimationState();
}

class _RcletAnimationState extends State<RcletAnimation> {
  late final bool _shouldRepeat;
  late final bool _shouldAnimate;
  late final double _width;
  late final double _height;

  @override
  void initState() {
    super.initState();
    
    // Use provided values or fall back to type defaults
    _shouldRepeat = widget.repeat ?? widget.animationType.shouldLoop;
    _shouldAnimate = widget.animate ?? widget.animationType.shouldAutoPlay;
    
    final defaultSize = widget.animationType.defaultSize;
    _width = widget.width ?? defaultSize.width;
    _height = widget.height ?? defaultSize.height;
  }

  Widget _buildDefaultErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.animation,
            size: 32.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          Text(
            'Animation\nUnavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLoadingWidget(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Lottie.asset(
        widget.animationType.assetPath,
        width: _width,
        height: _height,
        fit: widget.fit,
        repeat: _shouldRepeat,
        reverse: widget.reverse,
        animate: _shouldAnimate,
        frameRate: widget.frameRate,
        alignment: widget.alignment,
        controller: widget.controller,
        onLoaded: widget.onLoaded,
        delegates: widget.delegates,
        options: widget.options,
        filterQuality: widget.filterQuality,
        errorBuilder: widget.errorBuilder ?? _buildDefaultErrorWidget,
        frameBuilder: (context, child, composition) {
          // Show loading widget while the animation is loading
          if (composition == null) {
            return widget.loadingBuilder?.call(context) ?? 
                   _buildDefaultLoadingWidget(context);
          }
          return child;
        },
      ),
    );
  }
}

/// Convenience factory methods for common animation scenarios
extension RcletAnimationFactory on RcletAnimation {
  /// Creates a full-screen loading animation
  static Widget fullscreenLoader({
    Color? backgroundColor,
    String? loadingText,
    TextStyle? textStyle,
  }) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const RcletAnimation(
              animationType: RcletAnimationType.loadingSpinner,
            ),
            if (loadingText != null) ...[
              SizedBox(height: 24.h),
              Text(
                loadingText,
                style: textStyle ?? TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates a success modal with animation
  static Widget successModal({
    required String title,
    required String message,
    VoidCallback? onDismiss,
    String? buttonText,
  }) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RcletAnimation(
                animationType: RcletAnimationType.gigSuccess,
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              if (onDismiss != null) ...[
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onDismiss,
                    child: Text(buttonText ?? 'Continue'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Creates an error dialog with animation
  static Widget errorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? retryText,
    String? dismissText,
  }) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RcletAnimation(
                animationType: RcletAnimationType.errorRed,
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  if (onDismiss != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        child: Text(dismissText ?? 'Cancel'),
                      ),
                    ),
                  if (onRetry != null && onDismiss != null)
                    SizedBox(width: 12.w),
                  if (onRetry != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onRetry,
                        child: Text(retryText ?? 'Retry'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates an empty state widget with animation
  static Widget emptyState({
    required String title,
    required String message,
    VoidCallback? onAction,
    String? actionText,
    IconData? actionIcon,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const RcletAnimation(
              animationType: RcletAnimationType.emptyState,
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.add),
                label: Text(actionText ?? 'Get Started'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}