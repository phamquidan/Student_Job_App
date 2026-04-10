import 'package:flutter/material.dart';

class ApplicantsListScreen extends StatelessWidget {
  const ApplicantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách ứng viên')),
      body: ListView(
        children: const [
          ListTile(title: Text('Nguyễn Văn A'), subtitle: Text('Ứng tuyển: Thực tập sinh Flutter'), trailing: Chip(label: Text('Pending'))),
          ListTile(title: Text('Trần Thị B'), subtitle: Text('Ứng tuyển: Part-time Content Marketing'), trailing: Chip(label: Text('Reviewed'))),
        ],
      ),
    );
  }
}
