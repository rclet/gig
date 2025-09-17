import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

/// Glassmorphic UI components for futuristic design
/// 
/// Provides frosted glass effects, animated borders, and shadows
/// for gig cards, modals, tooltips, and sidebars
class GlassmorphicContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final bool animateOnHover;
  final bool animateOnTap;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.animateOnHover = false,
    this.animateOnTap = false,
    this.onTap,
    this.gradient,
  });

  @override
  State<GlassmorphicContainer> createState() => _GlassmorphicContainerState();
}

class _GlassmorphicContainerState extends State<GlassmorphicContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (widget.animateOnHover) {
      setState(() {
        _isHovered = isHovered;
      });
      
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _handleTap() {
    if (widget.animateOnTap) {
      setState(() {
        _isTapped = true;
      });
      
      _animationController.forward().then((_) {
        _animationController.reverse().then((_) {
          setState(() {
            _isTapped = false;
          });
        });
      });
    }
    
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: GestureDetector(
              onTap: widget.onTap != null ? _handleTap : null,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16.r),
                  boxShadow: _buildBoxShadow(),
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur,
                      sigmaY: widget.blur,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.gradient ??
                            LinearGradient(
                              colors: [
                                Colors.white.withOpacity(widget.opacity),
                                Colors.white.withOpacity(widget.opacity * 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(16.r),
                        border: Border.all(
                          color: widget.borderColor ??
                              Colors.white.withOpacity(0.2),
                          width: widget.borderWidth,
                        ),
                      ),
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<BoxShadow> _buildBoxShadow() {
    if (widget.boxShadow != null) {
      return widget.boxShadow!;
    }

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20 * _glowAnimation.value,
        spreadRadius: 2 * _glowAnimation.value,
        offset: const Offset(0, 8),
      ),
      if (_isHovered || _isTapped)
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          blurRadius: 30 * _glowAnimation.value,
          spreadRadius: 4 * _glowAnimation.value,
          offset: const Offset(0, 12),
        ),
    ];
  }
}

/// Glassmorphic Card for Gig listings
class GlassmorphicGigCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const GlassmorphicGigCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      animateOnHover: true,
      animateOnTap: true,
      onTap: onTap,
      padding: padding ?? EdgeInsets.all(16.w),
      borderRadius: BorderRadius.circular(20.r),
      blur: 15.0,
      opacity: 0.15,
      borderColor: Colors.white.withOpacity(0.3),
      child: child,
    );
  }
}

/// Glassmorphic Modal Dialog
class GlassmorphicModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onClose;

  const GlassmorphicModal({
    super.key,
    required this.child,
    this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: 320.w,
        padding: EdgeInsets.all(24.w),
        borderRadius: BorderRadius.circular(24.r),
        blur: 20.0,
        opacity: 0.2,
        borderColor: Colors.white.withOpacity(0.3),
        borderWidth: 1.5,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 20),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (onClose != null)
                    GestureDetector(
                      onTap: onClose,
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.8),
                        size: 20.w,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Glassmorphic Tooltip
class GlassmorphicTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final TooltipDirection direction;

  const GlassmorphicTooltip({
    super.key,
    required this.child,
    required this.message,
    this.direction = TooltipDirection.top,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
      richMessage: WidgetSpan(
        child: GlassmorphicContainer(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          borderRadius: BorderRadius.circular(8.r),
          blur: 10.0,
          opacity: 0.8,
          borderColor: Colors.white.withOpacity(0.3),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

enum TooltipDirection { top, bottom, left, right }

/// Glassmorphic Sidebar
class GlassmorphicSidebar extends StatelessWidget {
  final Widget child;
  final double width;
  final bool isVisible;
  final VoidCallback? onClose;

  const GlassmorphicSidebar({
    super.key,
    required this.child,
    this.width = 280,
    this.isVisible = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isVisible ? width.w : 0,
      height: double.infinity,
      child: isVisible
          ? GlassmorphicContainer(
              width: width.w,
              height: double.infinity,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
              blur: 20.0,
              opacity: 0.15,
              borderColor: Colors.white.withOpacity(0.3),
              child: Column(
                children: [
                  if (onClose != null)
                    Container(
                      padding: EdgeInsets.all(16.w),
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onClose,
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.8),
                          size: 24.w,
                        ),
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Glassmorphic Bottom Sheet
class GlassmorphicBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;

  const GlassmorphicBottomSheet({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: GlassmorphicContainer(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        blur: 20.0,
        opacity: 0.2,
        borderColor: Colors.white.withOpacity(0.3),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            if (title != null) ...[
              SizedBox(height: 16.h),
              Text(
                title!,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
            ] else
              SizedBox(height: 20.h),
            
            child,
          ],
        ),
      ),
    );
  }
}