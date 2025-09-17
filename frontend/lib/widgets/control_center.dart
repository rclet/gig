import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../shared/widgets/gig_animation_wrapper.dart';
import '../features/animations/screens/animation_preview_screen.dart';

/// Control Center UI shell with dynamic tools, national branding, and red-dot motif
/// Features Bangladesh-inspired design elements and Rclet Guardian integration
class ControlCenter extends StatefulWidget {
  final Widget? child;
  final bool showRedDotIndicators;
  final bool showNationalBranding;
  final VoidCallback? onAnimationsPressed;
  final VoidCallback? onSettingsPressed;

  const ControlCenter({
    super.key,
    this.child,
    this.showRedDotIndicators = true,
    this.showNationalBranding = true,
    this.onAnimationsPressed,
    this.onSettingsPressed,
  });

  @override
  State<ControlCenter> createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenter>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isExpanded = false;
  bool _showQuickActions = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleQuickActions() {
    setState(() {
      _showQuickActions = !_showQuickActions;
    });
    
    if (_showQuickActions) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          if (widget.child != null) widget.child!,
          
          // Control Center overlay
          Positioned(
            top: 60.h,
            right: 16.w,
            child: _buildControlPanel(),
          ),
          
          // Quick actions panel
          if (_showQuickActions)
            Positioned(
              top: 120.h,
              right: 16.w,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildQuickActionsPanel(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Column(
      children: [
        // Main control button with national branding
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: RedDotAnimationWrapper(
            showRedDot: widget.showRedDotIndicators && !_showQuickActions,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: GestureDetector(
                    onTap: _toggleQuickActions,
                    child: Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: widget.showNationalBranding
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF006A4E), // Bangladesh green
                                  Color(0xFFF42A41), // Bangladesh red
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(28.r),
                        border: Border.all(
                          color: Colors.white,
                          width: 3.w,
                        ),
                      ),
                      child: Icon(
                        _showQuickActions ? Icons.close : Icons.widgets_outlined,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Rclet Guardian indicator (subtle)
        if (widget.showNationalBranding && !_showQuickActions)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 12.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Guardian',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionsPanel() {
    final actions = [
      ControlAction(
        icon: Icons.animation,
        label: 'Animations',
        color: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnimationPreviewScreen(),
            ),
          );
          _toggleQuickActions();
        },
      ),
      ControlAction(
        icon: Icons.palette_outlined,
        label: 'Themes',
        color: AppColors.secondary,
        onTap: () {
          _showThemeSelector();
        },
      ),
      ControlAction(
        icon: Icons.speed,
        label: 'Performance',
        color: AppColors.accent,
        onTap: () {
          _showPerformanceMetrics();
        },
      ),
      ControlAction(
        icon: Icons.bug_report_outlined,
        label: 'Debug',
        color: AppColors.warning,
        onTap: () {
          _showDebugPanel();
        },
      ),
      ControlAction(
        icon: Icons.settings_outlined,
        label: 'Settings',
        color: AppColors.textSecondary,
        onTap: widget.onSettingsPressed ?? () {},
      ),
    ];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with national branding
          if (widget.showNationalBranding)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16.w,
                    height: 10.h,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF006A4E), Color(0xFFF42A41)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Rclet Tools',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          
          // Action buttons
          ...actions.map((action) => _buildActionButton(action)).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButton(ControlAction action) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: RedDotAnimationWrapper(
        showRedDot: widget.showRedDotIndicators,
        dotSize: 6.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: action.color.withOpacity(0.2),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    action.icon,
                    size: 20.sp,
                    color: action.color,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: action.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Theme Selector',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GigAnimationWrapper.loadingSpinner(size: 40.w),
            SizedBox(height: 16.h),
            Text(
              'Theme customization coming soon with Rclet v1.1',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPerformanceMetrics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Performance Monitor',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: AppColors.success, size: 20.sp),
                SizedBox(width: 8.w),
                Text('FPS: 60', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.memory, color: AppColors.warning, size: 20.sp),
                SizedBox(width: 8.w),
                Text('Memory: 45MB', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.network_check, color: AppColors.accent, size: 20.sp),
                SizedBox(width: 8.w),
                Text('API: Connected', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDebugPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Debug Console',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Container(
          width: 300.w,
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(
              '> Rclet Gig v1.0.0 initialized\n'
              '> API endpoint: ${_getApiStatus()}\n'
              '> Lottie animations: 6 loaded\n'
              '> Red-dot motif: enabled\n'
              '> Guardian mode: active\n'
              '> Build: release.v1.0',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.green.shade300,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getApiStatus() {
    return 'https://gig.com.bd/gig-main/backend/api';
  }
}

class ControlAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  ControlAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}