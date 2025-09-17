import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

enum MascotState {
  idle,
  active,
  alert,
  success,
  error,
}

enum MascotSize {
  small,
  medium,
  large,
}

class RcletGuardianMascot {
  static const String _assetPath = 'assets/animations/rclet_guardian_mascot.json';
  
  static Future<Map<String, dynamic>?> _loadMascotData() async {
    try {
      final String jsonString = await rootBundle.loadString(_assetPath);
      return json.decode(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Get the appropriate message for a given context
  static Future<String> getContextMessage(String context) async {
    final data = await _loadMascotData();
    if (data != null && data['usage_contexts']?[context]?['message'] != null) {
      return data['usage_contexts'][context]['message'];
    }
    
    // Fallback messages
    switch (context) {
      case 'splash_screen':
        return 'Rclet Guardian is initializing...';
      case 'control_center':
        return 'Guardian is watching';
      case 'agent_status':
        return 'Online';
      case 'empty_state':
        return 'No gigs yet—Rclet Guardian is watching';
      case 'loading':
        return 'Guardian is working...';
      default:
        return 'Rclet Guardian';
    }
  }

  /// Get the fallback widget when mascot asset is unavailable
  static Widget getFallbackWidget({
    MascotSize size = MascotSize.medium,
    Color? color,
  }) {
    double iconSize;
    switch (size) {
      case MascotSize.small:
        iconSize = 24.sp;
        break;
      case MascotSize.medium:
        iconSize = 48.sp;
        break;
      case MascotSize.large:
        iconSize = 80.sp;
        break;
    }

    return Icon(
      Icons.shield,
      size: iconSize,
      color: color ?? AppColors.primary,
    );
  }

  /// Create the mascot widget with SVG representation
  static Widget buildMascotWidget({
    MascotSize size = MascotSize.medium,
    MascotState state = MascotState.idle,
    String? customMessage,
    bool showMessage = false,
  }) {
    double containerSize;
    double iconSize;
    
    switch (size) {
      case MascotSize.small:
        containerSize = 32.w;
        iconSize = 20.sp;
        break;
      case MascotSize.medium:
        containerSize = 64.w;
        iconSize = 40.sp;
        break;
      case MascotSize.large:
        containerSize = 120.w;
        iconSize = 80.sp;
        break;
    }

    Color eyeColor = _getEyeColor(state);
    Color coreColor = _getCoreColor(state);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mascot representation using Shield icon and decorations
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: eyeColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shield outline
              Icon(
                Icons.shield,
                size: iconSize,
                color: Colors.white,
              ),
              // Red core (Bangladesh flag inspired)
              Positioned(
                bottom: containerSize * 0.3,
                child: Container(
                  width: containerSize * 0.25,
                  height: containerSize * 0.25,
                  decoration: BoxDecoration(
                    color: coreColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Eyes
              Positioned(
                top: containerSize * 0.25,
                left: containerSize * 0.35,
                child: Container(
                  width: containerSize * 0.08,
                  height: containerSize * 0.08,
                  decoration: BoxDecoration(
                    color: eyeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: eyeColor.withOpacity(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: containerSize * 0.25,
                right: containerSize * 0.35,
                child: Container(
                  width: containerSize * 0.08,
                  height: containerSize * 0.08,
                  decoration: BoxDecoration(
                    color: eyeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: eyeColor.withOpacity(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showMessage) ...[
          SizedBox(height: 8.h),
          FutureBuilder<String>(
            future: Future.value(customMessage ?? 'Rclet Guardian'),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Rclet Guardian',
                style: TextStyle(
                  fontSize: size == MascotSize.small ? 10.sp : 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ],
      ],
    );
  }

  static Color _getEyeColor(MascotState state) {
    switch (state) {
      case MascotState.idle:
        return const Color(0xFF00FF88); // Bright green
      case MascotState.active:
        return const Color(0xFF00FF88); // Bright green
      case MascotState.alert:
        return const Color(0xFF00FF88); // Bright green
      case MascotState.success:
        return const Color(0xFF10B981); // Success green
      case MascotState.error:
        return AppColors.error; // Red for errors
    }
  }

  static Color _getCoreColor(MascotState state) {
    switch (state) {
      case MascotState.idle:
      case MascotState.active:
      case MascotState.alert:
      case MascotState.success:
        return const Color(0xFFDC143C); // Bangladesh flag red
      case MascotState.error:
        return AppColors.error;
    }
  }

  /// Create animated mascot with pulsing effect
  static Widget buildAnimatedMascot({
    MascotSize size = MascotSize.medium,
    MascotState state = MascotState.idle,
    String? customMessage,
    bool showMessage = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: _getAnimationDuration(state)),
      tween: Tween(begin: 0.8, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: buildMascotWidget(
            size: size,
            state: state,
            customMessage: customMessage,
            showMessage: showMessage,
          ),
        );
      },
    );
  }

  static int _getAnimationDuration(MascotState state) {
    switch (state) {
      case MascotState.idle:
        return 2000;
      case MascotState.active:
        return 1500;
      case MascotState.alert:
        return 1000;
      case MascotState.success:
        return 2500;
      case MascotState.error:
        return 1800;
    }
  }
}