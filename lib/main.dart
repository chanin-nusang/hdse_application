import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/app.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/blocs/speech_to_text.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ApplicationBloc()),
    ChangeNotifierProvider<SpeechToTextService>(
        create: (context) => SpeechToTextService())
  ], child: MaterialApp(debugShowCheckedModeBanner: false, home: App())));
}
