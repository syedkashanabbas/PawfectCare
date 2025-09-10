import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawfectcare/homepage.dart';
import 'package:pawfectcare/login.dart';
import 'package:pawfectcare/signup.dart';
import 'package:pawfectcare/splash_screen.dart';
import 'package:pawfectcare/welcomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme()
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const login(),
        '/signup': (context) => const Signup(),

      },
    );
  }
}
