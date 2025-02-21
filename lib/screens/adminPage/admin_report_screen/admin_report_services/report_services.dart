import 'package:cloud_firestore/cloud_firestore.dart';

class ReportServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, String>>> getWorkshops() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('atolyeler').get();
      List<Map<String, String>> workshops = querySnapshot.docs.map((doc) {
        return {
          "name": doc["name"] as String,
          "collection": doc["collection"] as String,
          "nitelik": doc["nitelik"] as String,
        };
      }).toList();
      return workshops;
    } catch (e) {
      print("Error fetching workshops: $e");
      return [];
    }
  }

  /// Firestore'dan `urun` koleksiyonundaki `name` alanlarını çeker
  Future<List<String>> getToyNames(String collection,String name) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collection).get();

      List<String> names =
          querySnapshot.docs.map((doc) => doc[name] as String).toList();
      return names;

    } catch (e) {
      print("Error fetching toy names: $e");
      return [];
    }
  }

 /// Firestore'dan `toy_renk` koleksiyonundaki `renk` alanlarını çeker
  Future<List<String>> getToyColors() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('toy_renk').get();
      List<String> toyColors = querySnapshot.docs.map((doc) => doc["renk"] as String).toList();
      return toyColors;
    } catch (e) {
      print("Error fetching toy colors: $e");
      return [];
    }
  }
  /// Firestore'dan `boyut` koleksiyonundaki `renk` alanlarını çeker
  Future<List<String>> getToyBoyut() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('toy_height').get();
      List<String> toyBoyut = querySnapshot.docs.map((doc) => doc["boyut"] as String).toList();
      return toyBoyut;
    } catch (e) {
      print("Error fetching toy boyut: $e");
      return [];
    }
  }
  /// Firestore'dan `aksesuar` koleksiyonundaki `renk` alanlarını çeker
  Future<List<String>> getToyAksesuar() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('toy_aksesuar').get();
      List<String> toyAksesuar = querySnapshot.docs.map((doc) => doc["aksesuar"] as String).toList();
      return toyAksesuar;
    } catch (e) {
      print("Error fetching toy aksesuar: $e");
      return [];
    }
  }

  /// Firestore'dan `fine` koleksiyonundaki `renk` alanlarını çeker
  Future<List<String>> getFine() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('fine').get();
      List<String> fine = querySnapshot.docs.map((doc) => doc["fine"] as String).toList();
      return fine;
    } catch (e) {
      print("Error fetching toy fine: $e");
      return [];
    }
  }

  /// Firestore'dan `gramaj` koleksiyonundaki `renk` alanlarını çeker
  Future<List<String>> getGramaj() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('gramaj').get();
      List<String> gramaj = querySnapshot.docs.map((doc) => doc["gramaj"] as String).toList();
      return gramaj;
    } catch (e) {
      print("Error fetching toy gramaj: $e");
      return [];
    }
  }
/// Firestore'dan `denye` koleksiyonundaki `renk` alanlarını çeker
  Future<List<String>> getDenye() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('denye').get();
      List<String> denye = querySnapshot.docs.map((doc) => doc["denye"] as String).toList();
      return denye;
    } catch (e) {
      print("Error fetching toy denye: $e");
      return [];
    }
  }

}
