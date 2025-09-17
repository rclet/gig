import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/rclet_animation_wrapper.dart';
import '../widgets/rclet_control_center.dart';
import '../widgets/glassmorphic_components.dart';
import '../widgets/agent_feedback_console.dart';
import '../core/theme/app_colors.dart';

/// Demo screen showcasing all Rclet Gig Lottie Pack v1.0 components
class RcletDemoScreen extends ConsumerStatefulWidget {
  const RcletDemoScreen({super.key});

  @override
  ConsumerState<RcletDemoScreen> createState() => _RcletDemoScreenState();
}

class _RcletDemoScreenState extends ConsumerState<RcletDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  bool _showModal = false;
  bool _showBottomSheet = false;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDancing = ref.watch(dancingColorModeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDancing
              ? null
              : LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Rclet Gig Lottie Pack v1.0',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Futuristic UI Tools & Animation Demo',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Animation Showcase
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        children: [
                          _buildAnimationCard(
                            'Loading Spinner',
                            RcletAnimationWrapper.loadingSpinner(),
                            () => _logAction('Loading Spinner Tapped'),
                          ),
                          _buildAnimationCard(
                            'Success Tick',
                            RcletAnimationWrapper.successTick(),
                            () => _logAction('Success Tick Tapped'),
                          ),
                          _buildAnimationCard(
                            'Error Alert',
                            RcletAnimationWrapper.errorAlert(),
                            () => _logAction('Error Alert Tapped'),
                          ),
                          _buildAnimationCard(
                            'Empty State',
                            RcletAnimationWrapper.emptyState(),
                            () => _logAction('Empty State Tapped'),
                          ),
                          _buildAnimationCard(
                            'Onboarding',
                            RcletAnimationWrapper.onboardingHandshake(),
                            () => _logAction('Onboarding Handshake Tapped'),
                          ),
                          _buildAnimationCard(
                            'Tap Ripple',
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.touch_app, size: 40.w, color: AppColors.primary),
                                RcletAnimationWrapper.tapRipple(
                                  controller: _rippleController,
                                ),
                              ],
                            ),
                            () {
                              _rippleController.reset();
                              _rippleController.forward();
                              _logAction('Tap Ripple Triggered');
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _showModal = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: const Text('Show Modal'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _showBottomSheet = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: const Text('Show Bottom Sheet'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Rclet Control Center
            const RcletControlCenter(),
            
            // Agent Feedback Console
            const AgentFeedbackConsole(),
            
            // Console Toggle Button
            const ConsoleToggleButton(),
            
            // Modal overlay
            if (_showModal)
              Container(
                color: Colors.black54,
                child: Center(
                  child: GlassmorphicModal(
                    title: 'Glassmorphic Modal',
                    onClose: () => setState(() => _showModal = false),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'This is a futuristic glassmorphic modal with backdrop blur and animated borders.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        RcletAnimationWrapper.successTick(size: 60.w),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _showModal = false);
                            _logAction('Modal Closed');
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Bottom sheet overlay
            if (_showBottomSheet)
              GestureDetector(
                onTap: () => setState(() => _showBottomSheet = false),
                child: Container(
                  color: Colors.black54,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GlassmorphicBottomSheet(
                      title: 'Glassmorphic Bottom Sheet',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'This bottom sheet demonstrates the glassmorphic design with blur effects.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(
                                child: RcletAnimationWrapper.loadingSpinner(size: 30.w),
                              ),
                              Expanded(
                                child: RcletAnimationWrapper.successTick(size: 30.w),
                              ),
                              Expanded(
                                child: RcletAnimationWrapper.errorAlert(size: 30.w),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _showBottomSheet = false);
                              _logAction('Bottom Sheet Closed');
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationCard(String title, Widget animation, VoidCallback onTap) {
    return GlassmorphicGigCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Center(child: animation),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _logAction(String action) {
    AgentLogger.logAction(
      ref,
      action,
      'tap_ripple_micro.json',
      metadata: {'screen': 'demo', 'timestamp': DateTime.now().toIso8601String()},
    );
  }
}