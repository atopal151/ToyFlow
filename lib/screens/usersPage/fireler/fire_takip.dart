import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireTakip extends StatefulWidget {
  const FireTakip({super.key});

  @override
  State<FireTakip> createState() => _FireTakipState();
}

class _FireTakipState extends State<FireTakip> {
  // Firestore'dan kullanıcı rolünü al
  Future<String> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return (userDoc.data() as Map<String, dynamic>)['role'] ?? "Dokuma";
      }
    }
    return "Dokuma"; // Varsayılan değer
  }

  Stream<QuerySnapshot> getFireDataStream(String role) {
    // Rol ve koleksiyon eşlemesi
    final roleToCollectionMap = {
      "Dokuma": "dokuma_fire",
      "Kesim": "kesim_fire",
      "Dikim": "dikim_fire",
      "Dolum": "dolum_fire",
      "Paketleme": "paketleme_fire",
    };

    String collectionName = roleToCollectionMap[role] ?? "dokuma_fire";
    print("Kullanıcı rolü: $role, Seçilen koleksiyon: $collectionName");

    return FirebaseFirestore.instance.collection(collectionName).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fire Takip"),
      ),
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
                  var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  String urun = data['urun'] ?? 'Bilinmiyor';
                  String renk = data['renk'] ?? 'Bilinmiyor';
                  String boyut = data['boyut'] ?? 'Bilinmiyor';
                  String miktar = data['miktar'] != null ? "${data['miktar']} kg/adet" : 'Bilinmiyor';
                  String tarih = data['tarih'] != null ? (data['tarih'] as Timestamp).toDate().toString() : 'Tarih Bilinmiyor';

                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                          fontSize: 18,
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
                            "Tarih: $tarih",
                            style: const TextStyle(
                              fontSize: 11,
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
