import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ / CV')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
          SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: 'Họ và tên')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Trường')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Chuyên ngành')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Số điện thoại')),
          SizedBox(height: 20),
          FilledButton(onPressed: null, child: Text('Chọn CV PDF')),
          SizedBox(height: 8),
          Text('Bước tiếp theo: nối file_picker + Firebase Storage.'),
        ],
      ),
    );
  }
}
