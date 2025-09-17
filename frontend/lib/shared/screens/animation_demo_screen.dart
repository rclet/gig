import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rclet_animation.dart';

/// Demo screen to showcase all Rclet animations
class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen> {
  void _showSuccessModal() {
    showDialog(
      context: context,
      builder: (context) => RcletAnimation.successModal(
        title: 'Success!',
        message: 'This is a demonstration of the success modal with animation.',
        onDismiss: () => Navigator.of(context).pop(),
        buttonText: 'Awesome!',
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => RcletAnimation.errorDialog(
        title: 'Oops! Something went wrong',
        message: 'This is a demonstration of the error dialog with animation.',
        onRetry: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Retry action triggered!')),
          );
        },
        onDismiss: () => Navigator.of(context).pop(),
        retryText: 'Try Again',
        dismissText: 'Cancel',
      ),
    );
  }

  void _showFullscreenLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RcletAnimation.fullscreenLoader(
        loadingText: 'Processing your request...',
      ),
    );
    
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _showProposalAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        body: Center(
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
                    animationType: RcletAnimationType.proposalSent,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Proposal Sent!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your proposal is flying to the client right now!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Animation Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rclet Animation Showcase',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Interactive demo of all branded animations in the Gig Marketplace.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            
            // Individual Animations Section
            _buildSection(
              title: 'Individual Animations',
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.2,
                children: [
                  _buildAnimationCard(
                    title: 'Success',
                    animationType: RcletAnimationType.gigSuccess,
                    description: 'One-time success animation',
                  ),
                  _buildAnimationCard(
                    title: 'Proposal Sent',
                    animationType: RcletAnimationType.proposalSent,
                    description: 'Paper plane animation',
                  ),
                  _buildAnimationCard(
                    title: 'Loading',
                    animationType: RcletAnimationType.loadingSpinner,
                    description: 'Continuous loading spinner',
                  ),
                  _buildAnimationCard(
                    title: 'Error',
                    animationType: RcletAnimationType.errorRed,
                    description: 'Error state animation',
                  ),
                  _buildAnimationCard(
                    title: 'Empty State',
                    animationType: RcletAnimationType.emptyState,
                    description: 'Breathing empty box',
                  ),
                  _buildAnimationCard(
                    title: 'Chatbot Agent',
                    animationType: RcletAnimationType.chatbotAgent,
                    description: 'Friendly bot with blinking',
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Complete UI Patterns Section
            _buildSection(
              title: 'Complete UI Patterns',
              child: Column(
                children: [
                  _buildPatternButton(
                    title: 'Success Modal',
                    description: 'Complete success flow with animation',
                    icon: Icons.check_circle,
                    color: AppColors.success,
                    onTap: _showSuccessModal,
                  ),
                  SizedBox(height: 12.h),
                  _buildPatternButton(
                    title: 'Error Dialog',
                    description: 'Error handling with retry option',
                    icon: Icons.error,
                    color: AppColors.error,
                    onTap: _showErrorDialog,
                  ),
                  SizedBox(height: 12.h),
                  _buildPatternButton(
                    title: 'Fullscreen Loader',
                    description: 'Loading overlay with animation',
                    icon: Icons.hourglass_empty,
                    color: AppColors.info,
                    onTap: _showFullscreenLoader,
                  ),
                  SizedBox(height: 12.h),
                  _buildPatternButton(
                    title: 'Proposal Flow',
                    description: 'Custom proposal sent animation',
                    icon: Icons.send,
                    color: AppColors.secondary,
                    onTap: _showProposalAnimation,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Empty State Example
            _buildSection(
              title: 'Empty State Component',
              child: Container(
                height: 300.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.outline),
                ),
                child: RcletAnimation.emptyState(
                  title: 'No Items Found',
                  message: 'This is how the empty state component looks in practice.',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Action button tapped!')),
                    );
                  },
                  actionText: 'Take Action',
                  actionIcon: Icons.add_circle,
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Bengali Localization Note
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: AppColors.info,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Bengali Localization Ready',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'All animations support Bengali text and RTL layouts. The animation system is fully compatible with the existing localization infrastructure.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        child,
      ],
    );
  }

  Widget _buildAnimationCard({
    required String title,
    required RcletAnimationType animationType,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: RcletAnimation(
              animationType: animationType,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}