import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../core/theme/app_colors.dart';
import '../widgets/glassmorphic_components.dart';

/// Agent log entry model
class AgentLogEntry {
  final String action;
  final String animation;
  final DateTime timestamp;
  final String status;
  final Map<String, dynamic>? metadata;

  AgentLogEntry({
    required this.action,
    required this.animation,
    required this.timestamp,
    required this.status,
    this.metadata,
  });
}

/// UI State model
class UIStateModel {
  final String currentScreen;
  final String lastAction;
  final String activeAnimation;
  final Map<String, dynamic> stateData;

  UIStateModel({
    required this.currentScreen,
    required this.lastAction,
    required this.activeAnimation,
    required this.stateData,
  });
}

/// Provider for agent logs
final agentLogsProvider = StateProvider<List<AgentLogEntry>>((ref) => [
  AgentLogEntry(
    action: 'App Started',
    animation: 'gig_loading_spinner.json',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    status: 'success',
    metadata: {'startup_time': '1.2s'},
  ),
  AgentLogEntry(
    action: 'User Login',
    animation: 'booking_success_tick.json',
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    status: 'success',
    metadata: {'user_id': '12345'},
  ),
  AgentLogEntry(
    action: 'Load Gig List',
    animation: 'no_gigs_empty.json',
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    status: 'empty',
    metadata: {'search_query': 'Flutter developer'},
  ),
]);

/// Provider for current UI state
final uiStateProvider = StateProvider<UIStateModel>((ref) => UIStateModel(
  currentScreen: 'Home',
  lastAction: 'Load Gig List',
  activeAnimation: 'no_gigs_empty.json',
  stateData: {
    'gig_count': 0,
    'user_authenticated': true,
    'network_status': 'connected',
    'theme_mode': 'light',
  },
));

/// Provider for console visibility
final consoleVisibilityProvider = StateProvider<bool>((ref) => false);

/// Agent Feedback Console - Collapsible panel for debugging and monitoring
/// 
/// Shows:
/// - Current UI state
/// - Last animation triggered
/// - Agent logs with timestamps
/// - Real-time debugging information
class AgentFeedbackConsole extends ConsumerStatefulWidget {
  const AgentFeedbackConsole({super.key});

  @override
  ConsumerState<AgentFeedbackConsole> createState() => _AgentFeedbackConsoleState();
}

class _AgentFeedbackConsoleState extends ConsumerState<AgentFeedbackConsole>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(consoleVisibilityProvider);
    final uiState = ref.watch(uiStateProvider);
    final agentLogs = ref.watch(agentLogsProvider);

    // Animate visibility
    if (isVisible) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: GlassmorphicContainer(
          height: 300.h,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          blur: 20.0,
          opacity: 0.95,
          borderColor: AppColors.primary.withOpacity(0.3),
          borderWidth: 1.5,
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          child: Column(
            children: [
              _buildConsoleHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      // Left Panel - UI State
                      Expanded(
                        flex: 1,
                        child: _buildUIStatePanel(uiState),
                      ),
                      
                      SizedBox(width: 16.w),
                      
                      // Right Panel - Agent Logs
                      Expanded(
                        flex: 2,
                        child: _buildAgentLogsPanel(agentLogs),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsoleHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.developer_mode,
            color: AppColors.primary,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Text(
            'Agent Feedback Console',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _buildStatusIndicator(),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => ref.read(consoleVisibilityProvider.notifier).state = false,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withOpacity(0.8),
              size: 20.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'ACTIVE',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUIStatePanel(UIStateModel uiState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UI State',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStateItem('Screen', uiState.currentScreen),
                _buildStateItem('Last Action', uiState.lastAction),
                _buildStateItem('Active Animation', uiState.activeAnimation),
                SizedBox(height: 8.h),
                Text(
                  'State Data',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 4.h),
                ...uiState.stateData.entries.map(
                  (entry) => _buildStateItem(entry.key, entry.value.toString()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateItem(String key, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key:',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentLogsPanel(List<AgentLogEntry> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Agent Logs',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _clearLogs(),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[logs.length - 1 - index]; // Reverse order
              return _buildLogEntry(log);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogEntry(AgentLogEntry log) {
    Color statusColor;
    IconData statusIcon;
    
    switch (log.status) {
      case 'success':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'empty':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.info;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 12.w,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  log.action,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatTime(log.timestamp),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4.h),
          
          Row(
            children: [
              Text(
                'Animation: ',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Text(
                log.animation,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          if (log.metadata != null && log.metadata!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              'Metadata: ${log.metadata!.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }

  void _clearLogs() {
    ref.read(agentLogsProvider.notifier).state = [];
  }
}

/// Utility methods for logging agent actions
class AgentLogger {
  static void logAction(
    WidgetRef ref,
    String action,
    String animation, {
    String status = 'success',
    Map<String, dynamic>? metadata,
  }) {
    final logs = ref.read(agentLogsProvider);
    final newLog = AgentLogEntry(
      action: action,
      animation: animation,
      timestamp: DateTime.now(),
      status: status,
      metadata: metadata,
    );
    
    ref.read(agentLogsProvider.notifier).state = [...logs, newLog];
  }

  static void updateUIState(
    WidgetRef ref, {
    String? currentScreen,
    String? lastAction,
    String? activeAnimation,
    Map<String, dynamic>? stateData,
  }) {
    final currentState = ref.read(uiStateProvider);
    
    ref.read(uiStateProvider.notifier).state = UIStateModel(
      currentScreen: currentScreen ?? currentState.currentScreen,
      lastAction: lastAction ?? currentState.lastAction,
      activeAnimation: activeAnimation ?? currentState.activeAnimation,
      stateData: stateData ?? currentState.stateData,
    );
  }
}

/// Console toggle button for development
class ConsoleToggleButton extends ConsumerWidget {
  const ConsoleToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(consoleVisibilityProvider);

    return Positioned(
      bottom: 20.h,
      left: 20.w,
      child: GestureDetector(
        onTap: () => ref.read(consoleVisibilityProvider.notifier).state = !isVisible,
        child: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
            color: Colors.white,
            size: 24.w,
          ),
        ),
      ),
    );
  }
}