import 'dart:convert';
import 'package:dio/dio.dart';

class CvUtils {
  static Future<String> uploadBase64ToTmpFiles(String base64Str, String filename) async {
    final bytes = base64Decode(base64Str);
    final dio = Dio();
    
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
    });
    
    final response = await dio.post(
      'https://tmpfiles.org/api/v1/upload',
      data: formData,
    );
    
    if (response.statusCode == 200) {
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final url = data['data']['url']?.toString();
        if (url != null) {
          if (url.startsWith('https://tmpfiles.org/')) {
            return url.replaceFirst('https://tmpfiles.org/', 'https://tmpfiles.org/dl/');
          }
          return url;
        }
      }
    }
    throw Exception('Không thể tải tệp lên tmpfiles.org');
  }
}
