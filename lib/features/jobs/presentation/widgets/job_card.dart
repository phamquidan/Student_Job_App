import 'package:flutter/material.dart';

import '../../domain/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  Color _sourceColor() {
    switch (job.source) {
      case 'api':
        return Colors.orange;
      case 'recruiter':
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(job.companyName),
              const SizedBox(height: 4),
              Text('${job.location} • ${job.salaryText}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(job.jobType)),
                  Chip(label: Text(job.category)),
                  Chip(
                    label: Text(job.source),
                    backgroundColor: _sourceColor().withOpacity(0.12),
                    side: BorderSide(color: _sourceColor().withOpacity(0.2)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
