import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/app.dart';
import 'package:hdse_application/services/speech_to_text.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      home: MultiProvider(providers: [
    ChangeNotifierProvider<SpeechToTextService>(
        create: (context) => SpeechToTextService())
  ], child: App())));
}
