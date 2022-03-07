import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/screen/chatbot/chatbot_screen.dart';
import 'package:hdse_application/screen/home_screen.dart';
import 'package:hdse_application/screen/loading_screen.dart';
import 'package:hdse_application/screen/signin/login_screen.dart';
import 'package:hdse_application/blocs/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final Map<int, Color> _green200Map = {
  50: Colors.green[50]!,
  100: Colors.green[100]!,
  200: Colors.green[200]!,
  300: Colors.green[300]!,
  400: Colors.green[400]!,
  500: Colors.green[500]!,
  600: Colors.green[600]!,
  700: Colors.green[700]!,
  800: Colors.green[800]!,
  900: Colors.green[900]!,
};

final MaterialColor _green200Swatch =
    MaterialColor(Colors.green[200]!.value, _green200Map);

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('th')],
      title: 'HDSE',
      theme: ThemeData(
          textTheme: GoogleFonts.sarabunTextTheme(Theme.of(context).textTheme),
          primarySwatch: _green200Swatch),
      home: HomeScreen(
        title: "ยินดีต้อนรับ",
      ), // Home(title: 'บริการข้อมูลสุขภาพสำหรับผู้สูงอายุ'),
    );
  }
}
