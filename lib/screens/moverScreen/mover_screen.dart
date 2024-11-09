import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class MoverScreen extends StatefulWidget {
  const MoverScreen({super.key});

  @override
  State<MoverScreen> createState() => _MoverScreenState();
}

class _MoverScreenState extends State<MoverScreen> {
  final AuthService _authService = Get.find();
  User? user = FirebaseAuth.instance.currentUser;
  String? userRole;
  int unreadCount = 0; // Okunmamış bildirim sayısı

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _fetchUnreadNotifications(); // Okunmamış bildirimleri al

    // Türkçe dil desteğini ekleyin
    timeago.setLocaleMessages('tr', timeago.TrShortMessages());
  }

  Future<void> _fetchUserRole() async {
    if (user != null) {
      userRole = await _authService.getUserRole(user!.uid);
      setState(() {});
    }
  }

  Future<void> _fetchUnreadNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('movers')
        .where('okundu', isEqualTo: false) // Okunmamış olanları filtrele
        .get();

    setState(() {
      unreadCount = snapshot.size; // Okunmamış bildirim sayısını güncelle
    });
  }

  Icon _getIcon(String islemTuru) {
    switch (islemTuru) {
      case "Stok Ekleme":
        return const Icon(Icons.add_circle, color: Colors.green,size: 18);
      case "Stok Güncelleme":
        return const Icon(Icons.update, color: Colors.blue,size: 18);
      case "Fire Kaydı":
        return const Icon(Icons.delete_rounded, color: Colors.red,size: 18);
      case "Stok Düşümü":
        return const Icon(Icons.download, color: Colors.orange,size: 18);
      default:
        return const Icon(Icons.info, color: Colors.grey,size: 18);
    }
  }

  void _markAsRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('movers')
        .doc(docId)
        .update({'okundu': true});

    _fetchUnreadNotifications(); // Okunmamış bildirim sayısını güncelle
  }

  Future<void> _markAllAsRead() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('movers')
        .where('okundu', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'okundu': true});
    }

    _fetchUnreadNotifications(); // Okunmamış bildirim sayısını güncelle
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
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('movers')
                  .where('atelye',
                      isEqualTo: userRole == 'admin' ? null : userRole)
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
                  return const Center(
                    child: Text("Hareket Yok"),
                  );
                }

                final hareketler = userRole == 'admin'
                    ? snapshot.data!.docs
                    : snapshot.data!.docs
                        .where((doc) => doc['atelye'] == userRole)
                        .toList();

                hareketler.sort(
                  (a, b) => (b['tarih'] as Timestamp)
                      .compareTo(a['tarih'] as Timestamp),
                );

                return RefreshIndicator(
                  onRefresh: _markAllAsRead,
                  child: ListView.builder(
                    itemCount: hareketler.length,
                    itemBuilder: (context, index) {
                      final hareket = hareketler[index];
                      final timestamp = hareket['tarih'] as Timestamp?;
                      final DateTime? tarih = timestamp?.toDate();
                      final formattedDate = tarih != null
                          ? timeago.format(tarih, locale: 'tr')
                          : 'Tarih yok';
                      final islemTuru = hareket['islemTuru'] as String;
                      final aciklama = hareket['aciklama'] as String;
                      final okunmadi = hareket['okundu'] == null ||
                          hareket['okundu'] == false;

                      return GestureDetector(
                        onTap: () {
                          if (okunmadi) {
                            _markAsRead(hareket.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: okunmadi
                                ? const Color.fromARGB(255, 213, 210, 210)
                                : Colors
                                    .transparent, // Okunmamışlar koyu renkte
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
                                      aciklama,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.notifications_active,color: Colors.grey,size:20),
                                  ),
                                  Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 11),
                                    )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
