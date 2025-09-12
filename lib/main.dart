import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawfectcare/Appointments/%20Unified_calendar_view.dart';
import 'package:pawfectcare/Appointments/Appointmentdetails.dart';
import 'package:pawfectcare/Common/Contactus.dart';
import 'package:pawfectcare/Common/Feedback.dart';
import 'package:pawfectcare/Common/Home_screen.dart';
import 'package:pawfectcare/Common/Notification.dart';
import 'package:pawfectcare/Common/Searchscreen.dart';
import 'package:pawfectcare/Common/User_profile.dart';
import 'package:pawfectcare/Petowner/Appointmentbooking.dart';
import 'package:pawfectcare/Petowner/Appointmenthistory.dart';
import 'package:pawfectcare/Petowner/Blogdetail.dart';
import 'package:pawfectcare/Petowner/Bloglist.dart';
import 'package:pawfectcare/Petowner/Petstore.dart';
import 'package:pawfectcare/Petowner/Productdetails.dart';
import 'package:pawfectcare/Petowner/Add_edit.dart';
import 'package:pawfectcare/Petowner/Dashboard.dart';
import 'package:pawfectcare/Petowner/Pethealth.dart';
import 'package:pawfectcare/Shelter/Add_edit_pet_listing.dart';
import 'package:pawfectcare/Shelter/Add_story.dart';
import 'package:pawfectcare/Shelter/Addoption_request.dart';
import 'package:pawfectcare/Shelter/Dashboard.dart';
import 'package:pawfectcare/Shelter/Donation_form.dart';
import 'package:pawfectcare/Shelter/Donation_list.dart';
import 'package:pawfectcare/Shelter/Petlisting.dart';
import 'package:pawfectcare/Shelter/Success_story.dart';
import 'package:pawfectcare/Shelter/Volunteer_form.dart';
import 'package:pawfectcare/Shelter/Volunteer_list.dart';
import 'package:pawfectcare/Vet/AddDiagnosisScreen.dart';
import 'package:pawfectcare/Vet/AppointmentCalendarScreen.dart';
import 'package:pawfectcare/Vet/AssignedPetsScreen.dart';
import 'package:pawfectcare/Vet/MedicalRecordScreen.dart';
import 'package:pawfectcare/Vet/UploadMedicalFilesScreen.dart';
import 'package:pawfectcare/Vet/VetDashboardScreen.dart';
import 'package:pawfectcare/homepage.dart';
import 'package:pawfectcare/auth/login.dart';
import 'package:pawfectcare/auth/signup.dart';
import 'package:pawfectcare/auth/splash_screen.dart';
import 'package:pawfectcare/auth/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // required on web
  );

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
        // Auth Screens URLs
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const login(),
        '/signup': (context) => const Signup(),

        // Pet Owner Screens URLs
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

        // Vet Dashboard Screens URLs
        '/vetdashboard': (context) => const VetDashboardScreen(),
        '/appointmentcalendar': (context) => const AppointmentCalendarScreen(),
        '/assignedpets': (context) => const AssignedPetsScreen(),
        '/medicalrecord': (context) => const MedicalRecordScreen(),
        '/adddiagnosis': (context) => const AddDiagnosisScreen(),
        '/uploadmedicalfiles': (context) => const UploadMedicalFilesScreen(),

        // Shelter Dashboard Screens URLs
        '/shelterdashboard': (context) => const ShelterDashboardScreen(),
        '/petlisting': (context) => const PetListingScreen(),
        '/add_editlisting': (context) => const ShelterPetProfileScreen(),
        '/adoption': (context) => const AdoptionRequestsScreen(),
        '/successstory': (context) => const SuccessStoriesScreen(),
        '/addstory': (context) => const AddStoryScreen(),
        '/volunteer': (context) => const VolunteerFormScreen(),
        '/donation': (context) => const DonationFormScreen(),
        '/donationlist': (context) => const DonationListScreen(),
        '/volunteerlist': (context) => const VolunteerListScreen(),

        // Common Screens URLs
        '/homescreen': (context) => const HomeScreen(role: 'Pet Owner'),
        '/userprofile': (context) => const UserProfileScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/contactus': (context) => const ContactUsScreen(),
        '/search': (context) => const SearchScreen(),
        '/feedback': (context) => const FeedbackScreen(),

        // Common Screens URLs
        '/unifiedcalender': (context) => const UnifiedCalendarView(),
        '/appointmentdetails': (context) => const AppointmentDetailsScreen(),


        



      },
    );
  }
}

