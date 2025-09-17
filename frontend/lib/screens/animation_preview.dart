import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/rclet_animation_wrapper.dart';
import '../core/theme/app_colors.dart';

/// Animation Preview Screen for Rclet Gig Lottie Pack v1.0
/// 
/// Displays all available animations in a scrollable grid with
/// metadata, usage context, and playback controls
class AnimationPreviewScreen extends StatefulWidget {
  const AnimationPreviewScreen({super.key});

  @override
  State<AnimationPreviewScreen> createState() => _AnimationPreviewScreenState();
}

class _AnimationPreviewScreenState extends State<AnimationPreviewScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? manifest;
  List<AnimationController> controllers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadManifest();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadManifest() async {
    try {
      final manifestString = await rootBundle
          .loadString('assets/animations/gig_pack_manifest.json');
      final manifestData = json.decode(manifestString);
      
      // Create animation controllers for each animation
      for (int i = 0; i < manifestData['animations'].length; i++) {
        controllers.add(AnimationController(
          duration: const Duration(seconds: 3),
          vsync: this,
        ));
      }
      
      setState(() {
        manifest = manifestData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load animation manifest: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Animation Preview',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _playAllAnimations,
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Play All',
          ),
          IconButton(
            onPressed: _stopAllAnimations,
            icon: const Icon(Icons.stop),
            tooltip: 'Stop All',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.w,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error Loading Animations',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              error = null;
                            });
                            _loadManifest();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildAnimationGrid(),
    );
  }

  Widget _buildAnimationGrid() {
    if (manifest == null) return const SizedBox.shrink();

    final animations = manifest!['animations'] as List<dynamic>;

    return Column(
      children: [
        // Header with pack info
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Text(
                manifest!['name'],
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Version ${manifest!['version']} • ${animations.length} animations',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                manifest!['description'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Animation grid
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.8,
              ),
              itemCount: animations.length,
              itemBuilder: (context, index) {
                final animation = animations[index];
                return _buildAnimationCard(animation, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationCard(Map<String, dynamic> animation, int index) {
    final controller = controllers[index];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animation display
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: RcletAnimationWrapper(
                    animationName: animation['filename'].split('.')[0],
                    controller: controller,
                    loop: true,
                    height: 80.w,
                    width: 80.w,
                    fallback: Icon(
                      _getIconForCategory(animation['category']),
                      size: 48.w,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Animation info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animation['name'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  Text(
                    animation['usage'],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // Duration and controls
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          animation['duration'],
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Play/Pause button
                      GestureDetector(
                        onTap: () => _toggleAnimation(controller),
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            controller.isAnimating
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 14.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'loading':
        return Icons.hourglass_empty;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'empty-state':
        return Icons.folder_open;
      case 'onboarding':
        return Icons.handshake;
      case 'interaction':
        return Icons.touch_app;
      default:
        return Icons.animation;
    }
  }

  void _toggleAnimation(AnimationController controller) {
    if (controller.isAnimating) {
      controller.stop();
    } else {
      controller.repeat();
    }
  }

  void _playAllAnimations() {
    for (var controller in controllers) {
      controller.repeat();
    }
  }

  void _stopAllAnimations() {
    for (var controller in controllers) {
      controller.stop();
    }
  }
}