import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductServices extends GetxController {
  // Kullanıcı e-posta adresini saklamak için bir değişken
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getCurrentUserEmail(); // Kullanıcı e-postasını almak için
  }

  Future<void> _getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userEmail.value = user.email ?? 'Email bulunamadı'; // E-posta adresini al
    } else {
      userEmail.value = 'Oturum açmamış'; // Kullanıcı oturumu açık değilse
    }
  }
}
