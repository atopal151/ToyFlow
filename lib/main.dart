import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toyflow/screens/login_screen/login_screen.dart';
import 'package:toyflow/screens/users/transfer_screen/transfer_screen.dart';
import 'package:toyflow/services/user_services/bottom_nav_bar.dart';
import 'package:toyflow/screens/users/atolye_screen/atolye_home_screen.dart';
import 'package:toyflow/services/user_services/auth_service.dart';
import 'package:toyflow/services/user_services/product_services.dart';
import 'package:toyflow/services/user_services/record_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // GetX servisleri başlat
  Get.put(AuthService());
  Get.put(ProductServices());
  Get.put(RecordServices());

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
      home: const AuthWrapper(), // SplashScreen yerine AuthWrapper kullanılıyor
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _navigateUser();
  }


Future<void> _navigateUser() async {
  await Future.delayed(const Duration(seconds: 3)); // Bekleme süresini artırdık

  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("Firebase kullanıcısı bulunamadı. Giriş ekranına yönlendiriliyor...");
      Get.offAll(() => const LoginScreen());
      return;
    }

    print("Firebase kullanıcısı bulundu: ${user.uid}");
    
    String? role;
    try {
      role = await _authService.getUserRole(user.uid);
    } catch (e) {
      print("Kullanıcı rolü alınırken hata oluştu: $e");
      Get.offAll(() => const LoginScreen()); // Hata olursa giriş ekranına yönlendir
      return;
    }

    if (role.isEmpty) {
      print("Kullanıcının rolü boş veya alınamadı. Giriş ekranına yönlendiriliyor...");
      Get.offAll(() => const LoginScreen());
      return;
    }

    print("Kullanıcı rolü: $role");

    if (role == "user") {
      _authService.logout();
      Get.offAll(() => const LoginScreen());
    } else if (role == 'admin') {
      Get.offAll(() => BottomNavBarWithPages());
    } else if (role == 'Dikim' ||
        role == 'Dokuma' ||
        role == 'Boyama' ||
        role == 'Dolum' ||
        role == 'Kesim' ||
        role == 'Paketleme') {
      Get.offAll(() => const AtolyeHomeScreen());
    } else if (role == 'Transfer') {
      Get.offAll(() => const TransferScreen());
    } else {
      print("Tanımsız rol: $role. Giriş ekranına yönlendiriliyor...");
      Get.offAll(() => const LoginScreen());
    }
  } catch (e) {
    print("Hata oluştu: $e");
    Get.offAll(() => const LoginScreen());
  }
}



  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Yükleme animasyonu
      ),
    );
  }
}
