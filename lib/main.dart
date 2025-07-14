import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Abah APK',
      theme: ThemeData(
        // Set Poppins sebagai default font untuk semua text
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.indigo,
      ),
      home: SplashScreen(),
    );
  }
}

