import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aqua_node/firebase_options.dart';
import 'package:aqua_node/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
  runApp(const AquaApp());
}
