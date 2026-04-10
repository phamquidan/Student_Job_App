import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.useFirebase) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppConfig.firebaseInitialized = true;
    } catch (e) {
      AppConfig.firebaseInitialized = false;
      debugPrint('Firebase init failed: $e');
    }
  }
  runApp(const ProviderScope(child: StudentJobApp()));
}
