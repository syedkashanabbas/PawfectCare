import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawfectcare/Petowner/Appointmentbooking.dart';
import 'package:pawfectcare/Petowner/Appointmenthistory.dart';
import 'package:pawfectcare/Petowner/Blogdetail.dart';
import 'package:pawfectcare/Petowner/Bloglist.dart';
import 'package:pawfectcare/Petowner/Petstore.dart';
import 'package:pawfectcare/Petowner/Productdetails.dart';
import 'package:pawfectcare/Petowner/add_edit.dart';
import 'package:pawfectcare/Petowner/dashboard.dart';
import 'package:pawfectcare/Petowner/pethealth.dart';
import 'package:pawfectcare/homepage.dart';
import 'package:pawfectcare/auth/login.dart';
import 'package:pawfectcare/auth/signup.dart';
import 'package:pawfectcare/auth/splash_screen.dart';
import 'package:pawfectcare/auth/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


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
        '/productdetail': (context) => ProductDetailScreen(
          name: "Josera Adult Food",
          price: "\$20",
          image: "https://via.placeholder.com/300x200.png?text=Josera+Adult+Food",
          description: "High-quality dry food made with natural ingredients.",
        ),
        '/bloglist': (context) => const BlogListScreen(),
        '/blogdetail': (context) => const BlogDetailScreen(title: "", image: "", description:"hi" ),
        '/shelter': (context) => const BlogListScreen(),


        

      },
    );
  }
}
