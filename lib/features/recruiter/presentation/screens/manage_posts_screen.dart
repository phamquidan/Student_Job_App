import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagePostsScreen extends StatelessWidget {
  const ManagePostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recruiter - Quản lý bài đăng'),
        actions: [
          IconButton(onPressed: () => context.push('/recruiter/post-job'), icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView(
        children: const [
          ListTile(title: Text('Thực tập sinh Flutter'), subtitle: Text('ABC Tech • TP.HCM'), trailing: Icon(Icons.chevron_right)),
          ListTile(title: Text('Part-time Sales Online'), subtitle: Text('Campus Shop • TP.HCM'), trailing: Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}
