import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/environment_config.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getJobs();
      
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          if (data is Map && data.containsKey('data')) {
            _jobs = List<Map<String, dynamic>>.from(data['data']);
          } else if (data is List) {
            _jobs = List<Map<String, dynamic>>.from(data);
          } else {
            _jobs = [];
          }
          _isLoading = false;
        });
      } else {
        // Fallback to mock data when API is not available
        setState(() {
          _jobs = _getMockJobs();
          _isLoading = false;
          _errorMessage = EnvironmentConfig.isDevelopment 
            ? 'Using mock data - ${result['message']}'
            : 'Loading jobs...';
        });
      }
    } catch (e) {
      // Fallback to mock data on error
      setState(() {
        _jobs = _getMockJobs();
        _isLoading = false;
        _errorMessage = EnvironmentConfig.isDevelopment 
          ? 'Using mock data - Connection error'
          : null;
      });
    }
  }

  List<Map<String, dynamic>> _getMockJobs() {
    return List.generate(10, (index) => {
      'id': index + 1,
      'title': 'Flutter Mobile App Development',
      'company': 'Tech Company ${index + 1}',
      'budget_min': (index + 1) * 500,
      'budget_max': (index + 1) * 800,
      'currency': 'USD',
      'location': index % 2 == 0 ? 'Remote' : 'Dhaka, Bangladesh',
      'skills': ['Flutter', 'Dart', 'Firebase'],
      'description': 'Looking for an experienced Flutter developer to build a cross-platform mobile application...',
      'created_at': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    color: EnvironmentConfig.isDevelopment 
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.info.withOpacity(0.1),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: EnvironmentConfig.isDevelopment 
                          ? AppColors.warning
                          : AppColors.info,
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: _jobs.isEmpty
                      ? const Center(
                          child: Text('No jobs available'),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _jobs.length,
                          itemBuilder: (context, index) {
                            final job = _jobs[index];
                            return _buildJobCard(
                              id: job['id']?.toString() ?? '${index + 1}',
                              title: job['title'] ?? 'Untitled Job',
                              company: job['company'] ?? job['client_name'] ?? 'Unknown Company',
                              budget: _formatBudget(job),
                              location: job['location'] ?? job['location_type'] ?? 'Not specified',
                              skills: _getSkills(job),
                              description: job['description'] ?? 'No description available',
                              onTap: () => context.go('/jobs/${job['id'] ?? index + 1}'),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatBudget(Map<String, dynamic> job) {
    final currency = job['currency'] ?? 'USD';
    final symbol = currency == 'BDT' ? '৳' : '\$';
    
    if (job['budget_min'] != null && job['budget_max'] != null) {
      return '$symbol${job['budget_min']} - $symbol${job['budget_max']}';
    } else if (job['budget'] != null) {
      return '$symbol${job['budget']}';
    } else {
      return 'Budget not specified';
    }
  }

  List<String> _getSkills(Map<String, dynamic> job) {
    if (job['skills'] is List) {
      return List<String>.from(job['skills']);
    } else if (job['required_skills'] is List) {
      return List<String>.from(job['required_skills']);
    } else if (job['tags'] is List) {
      return List<String>.from(job['tags']);
    } else {
      return ['Flutter', 'Dart']; // Default skills
    }
  }

  Widget _buildJobCard({
    required String id,
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