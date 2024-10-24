import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/SplashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toyflow/services/product_services.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase başlat
  Get.put(AuthService()); // Veya Get.lazyPut(() => AuthService());
  Get.put(ProductServices());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override 
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ToyFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}