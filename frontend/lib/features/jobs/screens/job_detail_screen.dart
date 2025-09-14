import 'package:flutter/material.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;
  
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Job Detail Screen - ID: $jobId'),
      ),
    );
  }
}