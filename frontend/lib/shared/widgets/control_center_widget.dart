import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/components/rclet_guardian_mascot.dart';

class ControlCenterWidget extends StatelessWidget {
  final VoidCallback? onTap;
  
  const ControlCenterWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mascot
            RcletGuardianMascot.buildAnimatedMascot(
              size: MascotSize.medium,
              state: MascotState.idle,
              showMessage: false,
            ),
            
            SizedBox(width: 16.w),
            
            // Control Center Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rclet Guardian',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FutureBuilder<String>(
                    future: RcletGuardianMascot.getContextMessage('control_center'),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Guardian is watching',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FF88),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Platform Secure',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status Indicator
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.7),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class AgentStatusIndicator extends StatelessWidget {
  final String status;
  final bool isOnline;
  
  const AgentStatusIndicator({
    super.key,
    this.status = 'Online',
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RcletGuardianMascot.buildMascotWidget(
            size: MascotSize.small,
            state: isOnline ? MascotState.idle : MascotState.error,
            showMessage: false,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rclet Guardian',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isOnline ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}