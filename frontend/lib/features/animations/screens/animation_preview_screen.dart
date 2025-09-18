import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gig_animation_wrapper.dart';

/// Animation Preview Screen for showcasing Lottie Pack v1.0
/// Features national branding, red-dot motif, and live previews
class AnimationPreviewScreen extends StatefulWidget {
  const AnimationPreviewScreen({super.key});

  @override
  State<AnimationPreviewScreen> createState() => _AnimationPreviewScreenState();
}

class _AnimationPreviewScreenState extends State<AnimationPreviewScreen> {
  int _selectedAnimationIndex = 0;
  bool _showRedDots = true;

  final List<AnimationPreviewItem> _animations = [
    AnimationPreviewItem(
      name: 'Loading Spinner',
      description: 'Smooth loading animation for data fetching',
      widget: GigAnimationWrapper.loadingSpinner(),
      category: 'Loading',
    ),
    AnimationPreviewItem(
      name: 'Empty State',
      description: 'Friendly empty state for no gigs available',
      widget: GigAnimationWrapper.emptyState(),
      category: 'States',
    ),
    AnimationPreviewItem(
      name: 'Success Tick',
      description: 'Celebration animation for successful bookings',
      widget: GigAnimationWrapper.success(),
      category: 'Feedback',
    ),
    AnimationPreviewItem(
      name: 'Error Alert',
      description: 'Alert animation for error notifications',
      widget: GigAnimationWrapper.error(),
      category: 'Feedback',
    ),
    AnimationPreviewItem(
      name: 'Onboarding Handshake',
      description: 'Welcome animation for new users',
      widget: GigAnimationWrapper.onboarding(),
      category: 'Onboarding',
    ),
    AnimationPreviewItem(
      name: 'Tap Ripple',
      description: 'Micro-interaction for touch feedback',
      widget: GigAnimationWrapper.tapRipple(),
      category: 'Interactions',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Rclet Gig Lottie Pack v1.0',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          // Bangladesh flag inspired accent
          Container(
            margin: EdgeInsets.only(right: 16.w),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 12.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF006A4E), Color(0xFFF42A41)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                RedDotAnimationWrapper(
                  showRedDot: _showRedDots,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _showRedDots = !_showRedDots;
                      });
                    },
                    icon: Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with Rclet Guardian mascot placeholder
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                // Rclet Guardian mascot placeholder
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2.w,
                    ),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Rclet Guardian',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Protecting your gig experience',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Animation categories
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: _getUniqueCategories().map((category) {
                final isSelected = _animations[_selectedAnimationIndex].category == category;
                return Container(
                  margin: EdgeInsets.only(right: 12.w),
                  child: RedDotAnimationWrapper(
                    showRedDot: _showRedDots && isSelected,
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onSelected: (selected) {
                        if (selected) {
                          final index = _animations.indexWhere((anim) => anim.category == category);
                          if (index != -1) {
                            setState(() {
                              _selectedAnimationIndex = index;
                            });
                          }
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Main animation preview
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Animation display area
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.outline,
                          width: 1.w,
                        ),
                      ),
                      child: Center(
                        child: _animations[_selectedAnimationIndex].widget,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Animation details
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _animations[_selectedAnimationIndex].name,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            RedDotAnimationWrapper(
                              showRedDot: _showRedDots,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  _animations[_selectedAnimationIndex].category,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _animations[_selectedAnimationIndex].description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation controls
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: RedDotAnimationWrapper(
                    showRedDot: _showRedDots && _selectedAnimationIndex > 0,
                    child: ElevatedButton.icon(
                      onPressed: _selectedAnimationIndex > 0
                          ? () {
                              setState(() {
                                _selectedAnimationIndex--;
                              });
                            }
                          : null,
                      icon: Icon(Icons.arrow_back, size: 16.sp),
                      label: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: RedDotAnimationWrapper(
                    showRedDot: _showRedDots && _selectedAnimationIndex < _animations.length - 1,
                    child: ElevatedButton.icon(
                      onPressed: _selectedAnimationIndex < _animations.length - 1
                          ? () {
                              setState(() {
                                _selectedAnimationIndex++;
                              });
                            }
                          : null,
                      icon: Icon(Icons.arrow_forward, size: 16.sp),
                      label: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueCategories() {
    return _animations.map((anim) => anim.category).toSet().toList();
  }
}

class AnimationPreviewItem {
  final String name;
  final String description;
  final Widget widget;
  final String category;

  AnimationPreviewItem({
    required this.name,
    required this.description,
    required this.widget,
    required this.category,
  });
}