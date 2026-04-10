import 'package:flutter/material.dart';

class PostJobScreen extends StatelessWidget {
  const PostJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng tin tuyển dụng')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Tiêu đề')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Công ty')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Địa điểm')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Lương')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Loại việc')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Ngành nghề')),
          SizedBox(height: 12),
          TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Mô tả')),
          SizedBox(height: 20),
          FilledButton(onPressed: null, child: Text('Đăng tin')),
        ],
      ),
    );
  }
}
