import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/rclet_animation.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _showEmpty = false;
  bool _isLoading = false;

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => RcletAnimation.errorDialog(
        title: 'Connection Error',
        message: 'Failed to load messages. Please check your internet connection and try again.',
        onRetry: () {
          Navigator.of(context).pop();
          _loadMessages();
        },
        onDismiss: () => Navigator.of(context).pop(),
        retryText: 'Retry',
        dismissText: 'Cancel',
      ),
    );
  }

  void _loadMessages() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    // Simulate error
    _showErrorDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => setState(() => _showEmpty = !_showEmpty),
            icon: Icon(_showEmpty ? Icons.chat : Icons.inbox),
            tooltip: _showEmpty ? 'Show Conversations' : 'Show Empty State',
          ),
          IconButton(
            onPressed: _showErrorDialog,
            icon: const Icon(Icons.error_outline),
            tooltip: 'Demo Error Dialog',
          ),
        ],
      ),
      body: _isLoading
          ? RcletAnimation.fullscreenLoader(
              backgroundColor: AppColors.background,
              loadingText: 'Loading conversations...',
              textStyle: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            )
          : _showEmpty
              ? _buildEmptyState()
              : _buildChatList(),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: RcletAnimation.emptyState(
            title: 'No Conversations Yet',
            message: 'Start connecting with clients and freelancers. Your conversations will appear here.',
            onAction: () => setState(() => _showEmpty = false),
            actionText: 'View Sample Chats',
            actionIcon: Icons.chat_bubble_outline,
          ),
        ),
        // Chatbot agent at the bottom
        Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              const RcletAnimation(
                animationType: RcletAnimationType.chatbotAgent,
                width: 40,
                height: 40,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rclet Assistant',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'I\'m here to help you with any questions!',
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
      ],
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 8, // Mock data
      itemBuilder: (context, index) {
        return _buildChatTile(
          name: 'Client ${index + 1}',
          lastMessage: index % 2 == 0 
              ? 'Great work on the project! When can we schedule the next milestone?'
              : 'I have some feedback on the latest update. Can we discuss?',
          time: index == 0 ? '2 min ago' : '${(index + 1) * 15} min ago',
          unreadCount: index < 3 ? index + 1 : 0,
          isOnline: index < 4,
        );
      },
    );
  }
  }

  Widget _buildChatTile({
    required String name,
    required String lastMessage,
    required String time,
    required int unreadCount,
    required bool isOnline,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () {
            // Navigate to chat detail
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                
                // Message Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}