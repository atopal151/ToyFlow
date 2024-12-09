import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductServices extends GetxController {
  // Kullanıcı bilgilerini saklamak için değişkenler
  var userEmail = ''.obs;
  var firstName = ''.obs; // Ad
  var lastName = ''.obs; // Soyad
  var role = ''.obs; // Rol
  var workshopName = ''.obs; //atolye ismi
  var atolyeCollection = ''.obs; //atolye ismi

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges(); // Kullanıcı giriş-çıkış durumlarını dinlemek için
  }

  // Oturum durumlarını dinleme
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Kullanıcı giriş yaptı, bilgileri al
        await _getUserDetails(user.uid);
      } else {
        // Kullanıcı çıkış yaptı, bilgileri sıfırla
        _resetUserDetails();
      }
    });
  }

  Future<void> getAtolyeCollectionDetails() async {
    try {
      // Firestore sorgusu: workshopName ile name alanı eşleşen belgeyi bul
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('name',
              isEqualTo: workshopName.value) // Değişken değerini kullanıyoruz
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Atölye bulunamadı: ${workshopName.value}");
        return;
      }

      // İlk belgeden "collection" alanını al
      String? fetchedCollection = querySnapshot.docs.first['collection'];

      print("Eşleşen Atölye Collection: $fetchedCollection");

      // Atölye koleksiyonunu ProductServices değişkenine ata
      atolyeCollection.value =
          fetchedCollection ?? "Koleksiyon bilgisi bulunamadı";
      print("Atölye Collection Değeri: ${atolyeCollection.value}");
    } catch (e) {
      print("Atölye koleksiyon bilgisi alınırken hata oluştu: $e");
    }
  }

  // Kullanıcı bilgilerini Firestore'dan al
  Future<void> _getUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        userEmail.value =
            FirebaseAuth.instance.currentUser?.email ?? 'Email bulunamadı';
        firstName.value = data['firstName'] ?? 'Ad bulunamadı';
        lastName.value = data['lastName'] ?? 'Soyad bulunamadı';
        role.value = data['role'] ?? 'Rol bulunamadı';
        workshopName.value = data['workshop'] ?? "Atölye ismi bulunamadı.";
      } else {
        _resetUserDetails(); // Kullanıcı belgesi bulunamadıysa bilgileri sıfırla
      }
    } catch (e) {
      print("Firestore'dan veri alınırken hata: $e");
      _resetUserDetails();
    }
  }

  // Kullanıcı bilgilerini sıfırlama
  void _resetUserDetails() {
    userEmail.value = 'Oturum açmamış';
    firstName.value = 'Ad bulunamadı';
    lastName.value = 'Soyad bulunamadı';
    role.value = 'Rol bulunamadı';
    workshopName.value = 'Atölye ismi bulunamadı';
  }
}
