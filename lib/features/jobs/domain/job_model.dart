class JobModel {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final String salaryText;
  final String jobType;
  final String category;
  final String description;
  final String requirements;
  final String benefits;
  final String source;
  final String applyType;
  final String applyUrl;
  final String createdBy;
  final String status;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.salaryText,
    required this.jobType,
    required this.category,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.source,
    required this.applyType,
    required this.applyUrl,
    this.createdBy = '',
    this.status = 'open',
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      salaryText: map['salaryText']?.toString() ?? '',
      jobType: map['jobType']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      requirements: map['requirements']?.toString() ?? '',
      benefits: map['benefits']?.toString() ?? '',
      source: map['source']?.toString() ?? 'manual',
      applyType: map['applyType']?.toString() ?? 'internal',
      applyUrl: map['applyUrl']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? '',
      status: map['status']?.toString() ?? 'open',
    );
  }
}
