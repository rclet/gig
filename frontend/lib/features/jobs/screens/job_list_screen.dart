import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 10, // Mock data
        itemBuilder: (context, index) {
          return _buildJobCard(
            title: 'Flutter Mobile App Development',
            company: 'Tech Company ${index + 1}',
            budget: '\$${(index + 1) * 500} - \$${(index + 1) * 800}',
            location: index % 2 == 0 ? 'Remote' : 'Dhaka, Bangladesh',
            skills: ['Flutter', 'Dart', 'Firebase'],
            description: 'Looking for an experienced Flutter developer to build a cross-platform mobile application...',
            onTap: () => context.go('/jobs/job_${index + 1}'),
          );
        },
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required String company,
    required String budget,
    required String location,
    required List<String> skills,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outline),
        ),
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
              company,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.location_on, size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.monetization_on, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  budget,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: skills.map((skill) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}