import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductServices extends GetxController {
  // Kullanıcı bilgilerini saklamak için değişkenler
  var userEmail = ''.obs;
  var firstName = ''.obs; // Ad
  var lastName = ''.obs; // Soyad

  @override
  void onInit() {
    super.onInit();
    _getCurrentUserDetails(); // Kullanıcı bilgilerini almak için
  }

  Future<void> _getCurrentUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcının e-posta adresini al
      userEmail.value = user.email ?? 'Email bulunamadı';

      try {
        // Firestore'dan kullanıcı bilgilerini al
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          firstName.value = data['firstName'] ?? 'Ad bulunamadı'; // Ad
          lastName.value = data['lastName'] ?? 'Soyad bulunamadı'; // Soyad
        } else {
          firstName.value = 'Ad bulunamadı';
          lastName.value = 'Soyad bulunamadı';
        }
      } catch (e) {
        print("Firestore'dan veri alınırken hata: $e");
        firstName.value = 'Ad bulunamadı';
        lastName.value = 'Soyad bulunamadı';
      }
    } else {
      userEmail.value = 'Oturum açmamış'; // Kullanıcı oturumu açık değilse
      firstName.value = 'Ad bulunamadı';
      lastName.value = 'Soyad bulunamadı';
    }
  }
}
