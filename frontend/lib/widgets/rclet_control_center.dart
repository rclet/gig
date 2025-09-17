import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../core/theme/app_colors.dart';
import '../widgets/rclet_animation_wrapper.dart';

/// Provider for theme mode state
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Provider for dancing color mode state
final dancingColorModeProvider = StateProvider<bool>((ref) => false);

/// Provider for agent status
final agentStatusProvider = StateProvider<bool>((ref) => true);

/// Rclet Control Center - Floating futuristic UI control panel
/// 
/// Features:
/// - Dark/Light mode toggle with animated Lottie switch
/// - Dancing color mode toggle with animated gradient background
/// - Agent status indicator
/// - Quick actions for Create Gig and View Proposals
class RcletControlCenter extends ConsumerStatefulWidget {
  const RcletControlCenter({super.key});

  @override
  ConsumerState<RcletControlCenter> createState() => _RcletControlCenterState();
}

class _RcletControlCenterState extends ConsumerState<RcletControlCenter>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expansionController;
  late AnimationController _colorDanceController;
  late Animation<double> _expansionAnimation;
  late Animation<double> _colorDanceAnimation;

  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorDanceController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );
    
    _colorDanceAnimation = CurvedAnimation(
      parent: _colorDanceController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _colorDanceController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expansionController.forward();
      } else {
        _expansionController.reverse();
      }
    });
  }

  void _toggleColorDance() {
    final isDancing = ref.read(dancingColorModeProvider);
    ref.read(dancingColorModeProvider.notifier).state = !isDancing;
    
    if (!isDancing) {
      _colorDanceController.repeat();
    } else {
      _colorDanceController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDancing = ref.watch(dancingColorModeProvider);
    final isAgentActive = ref.watch(agentStatusProvider);

    return Positioned(
      right: 16.w,
      top: MediaQuery.of(context).padding.top + 100.h,
      child: AnimatedBuilder(
        animation: _colorDanceAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: isDancing
                  ? LinearGradient(
                      colors: [
                        HSVColor.fromAHSV(
                          1.0,
                          (_colorDanceAnimation.value * 360) % 360,
                          0.7,
                          0.9,
                        ).toColor(),
                        HSVColor.fromAHSV(
                          1.0,
                          ((_colorDanceAnimation.value * 360) + 120) % 360,
                          0.7,
                          0.9,
                        ).toColor(),
                        HSVColor.fromAHSV(
                          1.0,
                          ((_colorDanceAnimation.value * 360) + 240) % 360,
                          0.7,
                          0.9,
                        ).toColor(),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isDancing ? Colors.white : AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isExpanded ? 280.w : 56.w,
                    padding: EdgeInsets.all(12.w),
                    child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Icon(
          Icons.tune,
          color: Colors.white,
          size: 18.w,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    final themeMode = ref.watch(themeModeProvider);
    final isDancing = ref.watch(dancingColorModeProvider);
    final isAgentActive = ref.watch(agentStatusProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Rclet Control',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleExpansion,
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 18.w,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16.h),
        
        // Agent Status
        _buildGlassmorphicPanel(
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAgentActive ? Colors.green : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: (isAgentActive ? Colors.green : Colors.red)
                          .withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                isAgentActive ? 'Rclet Agent Active' : 'Agent Offline',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 12.h),
        
        // Theme Toggle
        _buildGlassmorphicPanel(
          child: Row(
            children: [
              Icon(
                themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white,
                size: 16.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final newMode = themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  ref.read(themeModeProvider.notifier).state = newMode;
                },
                child: Container(
                  width: 40.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: themeMode == ThemeMode.dark
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: themeMode == ThemeMode.dark
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      margin: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 12.h),
        
        // Dancing Color Mode
        _buildGlassmorphicPanel(
          child: Row(
            children: [
              RcletAnimationWrapper.tapRipple(size: 16.w),
              SizedBox(width: 8.w),
              Text(
                'Dancing Colors',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggleColorDance,
                child: Container(
                  width: 40.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    gradient: isDancing
                        ? const LinearGradient(
                            colors: [Colors.purple, Colors.pink, Colors.orange],
                          )
                        : null,
                    color: isDancing ? null : Colors.grey.shade300,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: isDancing
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      margin: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Quick Actions
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        _buildActionButton(
          'Create Gig',
          Icons.add_business,
          () => _showSnackBar('Create Gig feature coming soon!'),
        ),
        
        SizedBox(height: 8.h),
        
        _buildActionButton(
          'View Proposals',
          Icons.description,
          () => _showSnackBar('Proposals feature coming soon!'),
        ),
      ],
    );
  }

  Widget _buildGlassmorphicPanel({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _buildGlassmorphicPanel(
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.6),
              size: 12.w,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}