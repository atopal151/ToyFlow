// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/auth_service.dart';
import 'package:intl/intl.dart';

class UsersWorkScreen extends StatefulWidget {
  const UsersWorkScreen({super.key});

  @override
  State<UsersWorkScreen> createState() => _UsersWorkScreenState();
}

class _UsersWorkScreenState extends State<UsersWorkScreen> {
  String? _userRole;
  List<Map<String, dynamic>> _works = [];
  final AuthService _authService = AuthService();
  bool isLoading = false; // Yüklenme durumu için bir değişken eklendi

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndData();
  }

  Future<void> _fetchUserRoleAndData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userRole = await _authService.getUserRole(user.uid);

      try {
        QuerySnapshot querySnapshot;

        if (_userRole == 'Dokuma') {
          querySnapshot =
              await FirebaseFirestore.instance.collection('dokuma_work').get();
        } else if (_userRole == 'Boyama') {
          querySnapshot =
              await FirebaseFirestore.instance.collection('dokuma_stok').get();
        } else if (_userRole == 'Kesim') {
          querySnapshot =
              await FirebaseFirestore.instance.collection('boyama_stok').get();
        } else if (_userRole == 'Dikim') {
          querySnapshot =
              await FirebaseFirestore.instance.collection('kesim_stok').get();
        } else if (_userRole == 'Dolum') {
          querySnapshot =
              await FirebaseFirestore.instance.collection('dikim_stok').get();
        } else if (_userRole == 'Paketleme') {
          querySnapshot =
              await FirebaseFirestore.instance.collection('dolum_stok').get();
          print(querySnapshot);
        } else if (_userRole == 'Transfer') {
          querySnapshot = await FirebaseFirestore.instance
              .collection('paketleme_stok')
              .get();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Bu kullanıcı için geçerli bir iş yok.")),
          );
          return;
        }

        setState(() {
          _works =
              querySnapshot.docs.where((doc) => doc['miktar'] != 0).map((doc) {
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();
        });
      } catch (e) {
        print("Veriler alınırken hata oluştu: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı oturumu açık değil.")),
      );
    }
  }

  Future<void> transferAndResetStock() async {
    setState(() {
      isLoading = true; // Yükleme başlatılıyor
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot paketlemeStokSnapshot =
          await firestore.collection('paketleme_stok').get();

      for (var doc in paketlemeStokSnapshot.docs) {
        Map<String, dynamic> paketlemeData = doc.data() as Map<String, dynamic>;
        String urunAdi = paketlemeData['urun'];
        String? renk = paketlemeData['renk'];
        String? boyut = paketlemeData['boyut'];
        String? aksesuar = paketlemeData['aksesuar'];
        int adet = paketlemeData['miktar'];
        Timestamp tarih = Timestamp.now(); // O anki zamanı alıyoruz

        QuerySnapshot denizliDepoSnapshot = await firestore
            .collection('denizli_depo')
            .where('urun', isEqualTo: urunAdi)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .where('aksesuar', isEqualTo: aksesuar)
            .get();

        if (denizliDepoSnapshot.docs.isNotEmpty) {
          var denizliDepoDoc = denizliDepoSnapshot.docs.first;
          int mevcutAdet = denizliDepoDoc['miktar'];
          int yeniAdet = mevcutAdet + adet;

          await firestore
              .collection('denizli_depo')
              .doc(denizliDepoDoc.id)
              .update({
            'miktar': yeniAdet,
            'tarih': tarih,
          });
        } else {
          await firestore.collection('denizli_depo').add({
            'urun': urunAdi,
            'renk': renk,
            'boyut': boyut,
            'aksesuar': aksesuar,
            'miktar': adet,
            'tarih': tarih,
          });
        }

        await firestore
            .collection('paketleme_stok')
            .doc(doc.id)
            .update({'miktar': 0});
      }
      _fetchUserRoleAndData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ürünler Başarıyla Ana Depoya Aktarıldı.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktarım sırasında hata oluştu.')),
      );
      print("Aktarım sırasında hata oluştu: $e");
    } finally {
      setState(() {
        isLoading = false; // Yükleme tamamlandı
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bekleyen İşler",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          _userRole == "Transfer"
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () async {
                      await transferAndResetStock();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 142, 172, 83),
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.redo,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
        elevation: 0,
      ),
      body: _works.isEmpty
          ? Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'images/emptymov.webp',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _works.length,
              itemBuilder: (context, index) {
                final work = _works[index];
                String eklemeTarihi = 'Bilinmiyor';

                if (work['tarih'] != null && work['tarih'] is Timestamp) {
                  Timestamp timestamp = work['tarih'];
                  DateTime dateTime = timestamp.toDate();
                  eklemeTarihi = DateFormat('dd.MM.yyyy').format(dateTime);
                }

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'images/fullmov.webp',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userRole == 'Dokuma' && work['urun'] != null
                                    ? 'Dokunacak ${work['urun']}'
                                    : _userRole == 'Paketleme' &&
                                            work['urun'] != null
                                        ? 'Paketlenecek ${work['urun']}'
                                        : _userRole == 'Boyama' &&
                                                work['urun'] != null
                                            ? 'Boyanacak ${work['urun']}'
                                            : _userRole == 'Dolum' &&
                                                    work['urun'] != null
                                                ? 'Doldurulacak ${work['urun']}'
                                                : _userRole == 'Dikim' &&
                                                        work['urun'] != null
                                                    ? 'Dikilecek ${work['urun']}'
                                                    : _userRole == 'Kesim' &&
                                                            work['urun'] != null
                                                        ? 'Kesilecek ${work['urun']}'
                                                        : _userRole ==
                                                                    'Transfer' &&
                                                                work['urun'] !=
                                                                    null
                                                            ? 'Aktarılacak ${work['urun']}'
                                                            : (work['urun'] ??
                                                                'Ürün Yok'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (work['gramaj'] != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.scale,
                                            color: Color.fromARGB(
                                                255, 208, 139, 93),
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          work['gramaj'] ?? '--',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  if (work['fine'] != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.line_style,
                                            color: Color.fromARGB(
                                                255, 91, 166, 204),
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          work['fine'] ?? '--',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  if (work['denye'] != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.texture,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          work['denye'] ?? '--',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  if (work['renk'] != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.color_lens,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          work['renk'] ?? '--',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  
                                  if (work['boyut'] != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.straighten,
                                            color: Colors.blueGrey, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${work['boyut']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                                    const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.layers,
                                      color: Colors.blueGrey, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${work['miktar'] ?? 0} Kg/adet',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
