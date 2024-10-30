import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';

class MoverScreen extends StatefulWidget {
  const MoverScreen({super.key});

  @override
  State<MoverScreen> createState() => _MoverScreenState();
}

class _MoverScreenState extends State<MoverScreen> {
  final AuthService _authService = Get.find();
  User? user = FirebaseAuth.instance.currentUser;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  // Kullanıcı rolünü alıp userRole değişkenine atama
  Future<void> _fetchUserRole() async {
    if (user != null) {
      userRole = await _authService.getUserRole(user!.uid);
      print('User Role: $userRole'); // userRole'u kontrol et
      setState(() {}); // State'i güncelleyerek StreamBuilder'ın rolü almasını sağlıyoruz
    }
  }

  Icon _getIcon(String islemTuru) {
    switch (islemTuru) {
      case "Stok Ekleme":
        return const Icon(Icons.add_circle, color: Colors.green);
      case "Stok Güncelleme":
        return const Icon(Icons.update, color: Colors.blue);
      case "Fire Kaydı":
        return const Icon(Icons.delete_rounded, color: Colors.red);
      case "Stok Düşümü":
        return const Icon(Icons.download, color: Colors.orange);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atölye Hareketleri',
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0,
      ),
      body: userRole == null
          ? const Center(
              child: CircularProgressIndicator()) // userRole yüklenmesini bekliyor
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('movers')
                  // Eğer kullanıcı admin değilse filtre uygula
                  .where('atelye', isEqualTo: userRole == 'admin' ? null : userRole)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Bir hata oluştu: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print("No documents found for role: $userRole");
                  return const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 130,
                          backgroundImage: AssetImage('images/empty.webp'),
                        ),
                      ],
                    ),
                  );
                }

                // "Admin" kullanıcılar tüm verileri görür, diğer kullanıcılar kendi role göre filtrelenmiş verileri görür
                final hareketler = userRole == 'admin'
                    ? snapshot.data!.docs
                    : snapshot.data!.docs.where((doc) => doc['atelye'] == userRole).toList();

                // Eğer filtrelenmiş liste boşsa kullanıcıya bildirin
                if (hareketler.isEmpty) {
                  return const Center(
                    child: Text("Hareket Yok"),
                  );
                }

                // Sıralama işlemi uygulama tarafında yapılıyor
                hareketler.sort((a, b) => (b['tarih'] as Timestamp)
                    .compareTo(a['tarih'] as Timestamp));

                return ListView.builder(
                  itemCount: hareketler.length,
                  itemBuilder: (context, index) {
                    final hareket = hareketler[index];
                    final timestamp = hareket['tarih'] as Timestamp?;
                    final tarih = timestamp != null ? timestamp.toDate() : null;
                    final formattedDate = tarih != null
                        ? '${tarih.day.toString().padLeft(2, '0')}/${tarih.month.toString().padLeft(2, '0')}/${tarih.year} ${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}'
                        : 'Tarih yok';
                    final islemTuru = hareket['islemTuru'] as String;
                    final aciklama = hareket['aciklama'] as String;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: _getIcon(islemTuru),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    islemTuru,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$aciklama - $formattedDate',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
