import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/proposals_service.dart';
import '../../../core/error_mapper.dart';

class MyProposalsScreen extends ConsumerStatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  ConsumerState<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends ConsumerState<MyProposalsScreen> {
  List<dynamic> _proposals = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ProposalsService.getMyProposals();
      setState(() {
        _proposals = result['data'] ?? [];
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProposal(String proposalId) async {
    try {
      await ProposalsService.deleteProposal(proposalId);
      _loadProposals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal deleted')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Proposals'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadProposals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_proposals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No proposals yet',
              style: TextStyle(fontSize: 18.sp, color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Text(
              'Submit proposals to jobs to get started',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProposals,
      child: ListView.builder(
        itemCount: _proposals.length,
        padding: EdgeInsets.all(16.w),
        itemBuilder: (context, index) {
          final proposal = _proposals[index];
          final id = proposal['id']?.toString() ?? '';
          final jobTitle = proposal['job']?['title']?.toString() ?? 'Job';
          final bidAmount = proposal['bid_amount']?.toString() ?? '0';
          final status = proposal['status']?.toString() ?? 'pending';
          final coverLetter = proposal['cover_letter']?.toString() ?? '';

          return Card(
            margin: EdgeInsets.only(bottom: 16.h),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          jobTitle,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusChip(status),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Bid Amount: \$$bidAmount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (coverLetter.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      coverLetter,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (status == 'pending') ...[
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Navigate to edit proposal
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        ),
                        SizedBox(width: 8.w),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Proposal'),
                                content: const Text(
                                  'Are you sure you want to delete this proposal?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteProposal(id);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }
}
