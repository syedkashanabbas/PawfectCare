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
import 'package:pawfectcare/Petowner/AvailablePetsScreen.dart';
import 'package:pawfectcare/Petowner/Blogdetail.dart';
import 'package:pawfectcare/Petowner/Bloglist.dart';
import 'package:pawfectcare/Petowner/Petstore.dart';
import 'package:pawfectcare/Petowner/Productdetails.dart';
import 'package:pawfectcare/Petowner/Add_edit.dart';
import 'package:pawfectcare/Petowner/Dashboard.dart';
import 'package:pawfectcare/Petowner/Pethealth.dart';
import 'package:pawfectcare/Petowner/pet_vet_assignment.dart';
import 'package:pawfectcare/Shelter/Add_edit_pet_listing.dart';
import 'package:pawfectcare/Shelter/Add_editblog.dart';
import 'package:pawfectcare/Shelter/Add_story.dart';
import 'package:pawfectcare/Shelter/Addoption_request.dart';
import 'package:pawfectcare/Shelter/AdminNotificationScreen.dart';
import 'package:pawfectcare/Shelter/AdminPetsListing.dart';
import 'package:pawfectcare/Shelter/Dashboard.dart';
import 'package:pawfectcare/Shelter/Donation_form.dart';
import 'package:pawfectcare/Shelter/Donation_list.dart';
import 'package:pawfectcare/Shelter/Petlisting.dart';
import 'package:pawfectcare/Shelter/ShelterBlogListScreen.dart';
import 'package:pawfectcare/Shelter/Success_story.dart';
import 'package:pawfectcare/Shelter/Volunteer_form.dart';
import 'package:pawfectcare/Shelter/Volunteer_list.dart';
import 'package:pawfectcare/Store/Add_product.dart';
import 'package:pawfectcare/Store/CartScreen.dart';
import 'package:pawfectcare/Store/Edit_product.dart';
import 'package:pawfectcare/Store/OrdersListScreen.dart';
import 'package:pawfectcare/Store/Store_product_detail.dart';
import 'package:pawfectcare/Store/Store_product_list.dart';
import 'package:pawfectcare/Store/Store_home.dart';
import 'package:pawfectcare/Store/Store_wishlist.dart';
import 'package:pawfectcare/Store/ThankYouScreen.dart';
import 'package:pawfectcare/Vet/AddDiagnosisScreen.dart';
import 'package:pawfectcare/Vet/AppointmentCalendarScreen.dart';
import 'package:pawfectcare/Vet/AssignedPetsScreen.dart';
import 'package:pawfectcare/Vet/MedicalRecordScreen.dart';
import 'package:pawfectcare/Vet/UploadMedicalFilesScreen.dart';
import 'package:pawfectcare/Vet/VetAssignmentScreen.dart';
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

  await Firebase.initializeApp (
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
        '/assignPet': (context) => const AssignVetToPetScreen(),
        '/appointmenthistory': (context) => AppointmentHistoryScreen(),
        '/availablepets':(context)=>AvailablePetsScreen(),
        '/petstore': (context) =>  PetStoreScreen(),
        '/productdetail': (context) => ProductDetailScreen(
          name: "Josera Adult Food",
          price: "\$20",
          image: "https://via.placeholder.com/300x200.png?text=Josera+Adult+Food",
          description: "High-quality dry food made with natural ingredients.",
        ),
        '/bloglist': (context) => const BlogListScreen(),
        '/blogdetail': (context) => const BlogDetailScreen(),

        // Vet Dashboard Screens URLs
        '/vetdashboard': (context) => const VetDashboardScreen(),
        '/appointmentcalendar': (context) => const AppointmentCalendarScreen(),
        '/assignedpets': (context) => const AssignedPetsScreen(),
        '/medicalrecord': (context) => const MedicalRecordScreen(),
        '/vetassignments': (context) => const VetAssignmentScreen(),
        '/adddiagnosis': (context) => AddDiagnosisScreen(
          petId: ModalRoute.of(context)?.settings.arguments as String,  // Pass petId here
        ),
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
        '/bloglistshelter': (context) => const ShelterBlogListScreen(),
        '/volunteerlist': (context) => const VolunteerListScreen(),
        '/add_editblog': (context) => const AddEditBlogScreen(),
        '/admin_petlisting': (context) => const AdminPetsListing(),
        '/admin_notifications':(context)=> const AdminNotificationScreen(),

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

        // Store Screens URLs
        '/storehome': (context) => const StoreHomeScreen(),
        '/storelist': (context) => const ProductListScreen(),
        '/storedetail': (context) {
          final productId = ModalRoute.of(context)!.settings.arguments as String;
          return ProductDetailsScreen(productId: productId);
        },
        '/cart': (context) => const CartScreen(),
        '/storewishlist': (context) => const  WishlistScreen(),
        '/addproduct': (context) => const  ShelterUploadProductScreen(),
        '/thankyou': (context) => const  ThankYouScreen(),
        '/orderslist': (context) => const  OrdersListScreen(),
        '/editproduct': (context) => const  AdminProductScreen(),









      },
    );
  }
}

