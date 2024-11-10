import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class FireTakip extends StatefulWidget {
  const FireTakip({super.key});

  @override
  State<FireTakip> createState() => _FireTakipState();
}

class _FireTakipState extends State<FireTakip> {
  @override
  void initState() {
    super.initState();
    // Türkçe dil desteğini ekleyin
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  // Firestore'dan kullanıcı rolünü al
Future<String> getUserRole() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      return (userDoc.data() as Map<String, dynamic>)['role'] ?? "Rol bulunamadı";
    } else {
      print("Uyarı: Kullanıcı rolü bulunamadı, varsayılan değer kullanılacak.");
    }
  } else {
    print("Uyarı: Kullanıcı oturumu bulunamadı.");
  }
  return ""; // Boş değer veya varsayılan rol bulunamadı uyarısı
}


  Stream<QuerySnapshot> getFireDataStream(String role) {
  // Rol ve koleksiyon eşlemesi
  final roleToCollectionMap = {

    "Boyama": "boyama_fire",
    "Dokuma": "dokuma_fire",
    "Kesim": "kesim_fire",
    "Dikim": "dikim_fire",
    "Dolum": "dolum_fire",
    "Paketleme": "paketleme_fire",
  };

  if (roleToCollectionMap.containsKey(role)) {
    String collectionName = roleToCollectionMap[role]!;
    print("Kullanıcı rolü: $role, Seçilen koleksiyon: $collectionName");
    
    return FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('tarih', descending: true)
        .snapshots();
  } else {
    print("Uyarı: Belirtilen rol için geçerli bir koleksiyon bulunamadı.");
    return const Stream.empty(); // Geçerli bir koleksiyon yoksa boş bir stream döndür
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<String>(
        future: getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Rol bulunamadı.'));
          }

          String role = snapshot.data!;
          return StreamBuilder<QuerySnapshot>(
            stream: getFireDataStream(role),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Veri bulunamadı.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  String urun = data['urun'] ?? 'Bilinmiyor';
                  String renk = data['renk'] ?? 'Bilinmiyor';
                  String boyut = data['boyut'] ?? 'Bilinmiyor';
                  String miktar = data['miktar'] != null
                      ? "${data['miktar']} kg/adet"
                      : 'Bilinmiyor';
// Tarihi kontrol et ve biçimlendir
                  String tarih = data['tarih'] != null
                      ? timeago.format((data['tarih'] as Timestamp).toDate(),
                          locale: 'tr')
                      : 'Tarih Bilinmiyor';

                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 208, 93, 64),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      title: Text(
                        urun,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            "Miktar: $miktar",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tarih,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
