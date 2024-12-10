import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductServices extends GetxController { 
  var userEmail = ''.obs;
  var firstName = ''.obs; 
  var lastName = ''.obs;  
  var role = ''.obs;  
  var workshopName = ''.obs;  
  var atolyeCollection = ''.obs;  

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();  
  }
 
  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) { 
        await _getUserDetails(user.uid);
      } else { 
        _resetUserDetails();
      }
    });
  }

  Future<void> getAtolyeCollectionDetails() async {
    try { 
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('name',
              isEqualTo: workshopName.value)  
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Atölye bulunamadı: ${workshopName.value}");
        return;
      } 
      String? fetchedCollection = querySnapshot.docs.first['collection'];

      print("Eşleşen Atölye Collection: $fetchedCollection");
 
      atolyeCollection.value =
          fetchedCollection ?? "Koleksiyon bilgisi bulunamadı";
      print("Atölye Collection Değeri: ${atolyeCollection.value}");
    } catch (e) {
      print("Atölye koleksiyon bilgisi alınırken hata oluştu: $e");
    }
  }
 
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
        _resetUserDetails();  
      }
    } catch (e) {
      print("Firestore'dan veri alınırken hata: $e");
      _resetUserDetails();
    }
  }
 
  void _resetUserDetails() {
    userEmail.value = 'Oturum açmamış';
    firstName.value = 'Ad bulunamadı';
    lastName.value = 'Soyad bulunamadı';
    role.value = 'Rol bulunamadı';
    workshopName.value = 'Atölye ismi bulunamadı';
  }
}
