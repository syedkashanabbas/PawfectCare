import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawfectcare/Petowner/Appointmentbooking.dart';
import 'package:pawfectcare/Petowner/Appointmenthistory.dart';
import 'package:pawfectcare/Petowner/Petstore.dart';
import 'package:pawfectcare/Petowner/add_edit.dart';
import 'package:pawfectcare/Petowner/dashboard.dart';
import 'package:pawfectcare/Petowner/pethealth.dart';
import 'package:pawfectcare/homepage.dart';
import 'package:pawfectcare/auth/login.dart';
import 'package:pawfectcare/auth/signup.dart';
import 'package:pawfectcare/auth/splash_screen.dart';
import 'package:pawfectcare/auth/welcomeScreen.dart';

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
        '/petownerdashboard': (context) => const PetOwnerDashboard(),
        '/add_edit': (context) => const AddEditPetProfileScreen(),
        '/pethealth': (context) => const PetHealthScreen(),
        '/appointment': (context) => const BookAppointmentScreen(),
        '/appointmenthistory': (context) => AppointmentHistoryScreen(),
        '/petstore': (context) =>  PetStoreScreen(),

      },
    );
  }
}
