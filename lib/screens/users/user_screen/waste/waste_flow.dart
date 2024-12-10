import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toyflow/services/user_services/product_services.dart';

class FireTakip extends StatefulWidget {
  const FireTakip({super.key});

  @override
  State<FireTakip> createState() => _FireTakipState();
}

class _FireTakipState extends State<FireTakip> {
  final ProductServices _productServices = Get.find();

  @override
  void initState() {
    super.initState(); 
    timeago.setLocaleMessages('tr', timeago.TrShortMessages());
  }

  Stream<QuerySnapshot> getFireDataStream() {
    return FirebaseFirestore.instance
        .collection("fireler")
        .where("atolye", isEqualTo: _productServices.workshopName.value)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fire Takip"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getFireDataStream(),
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
              String urun = data['urun'] ?? '--';
              String renk = data['renk'] ?? '--';
              String boyut = data['boyut'] ?? '--';
              String gramaj = data['gramaj'] ?? '--';
              String fine = data['fine'] ?? '--';
              String denye = data['denye'] ?? '--';
              String miktar = data['miktar'] != null
                  ? "${data['miktar']} kg/adet"
                  : 'Bilinmiyor';
              String tarih = data['tarih'] != null
                  ? timeago.format((data['tarih'] as Timestamp).toDate(),
                      locale: 'tr')
                  : 'Tarih Bilinmiyor';

              return Card(
                color: Colors.white,
                elevation: 6,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'images/fire.webp',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        urun,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_productServices.role.value == "Dokuma")
                        Row(
                          children: [
                            const Icon(
                              Icons.lens,
                              color: Color.fromARGB(255, 99, 148, 182),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              denye,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      if (_productServices.role.value == "Boyama" ||
                          _productServices.role.value == "Kesim")
                        Row(
                          children: [
                            const Icon(
                              Icons.lens,
                              color: Color.fromARGB(255, 99, 148, 182),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              gramaj,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.height,
                              color: Color.fromARGB(255, 99, 148, 182),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              fine,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ),
                      Row(
                        children: [
                          if (_productServices.role.value == "Dikim" ||
                              _productServices.role.value == "Dolum" ||
                              _productServices.role.value == "Paketleme") ...[

                      const SizedBox(height: 4),
                            const Icon(
                              Icons.color_lens,
                              color: Color.fromARGB(255, 99, 148, 182),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              renk,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          if (_productServices.role.value == "Dikim" ||
                              _productServices.role.value == "Dolum" ||
                              _productServices.role.value == "Paketleme") ...[
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.height,
                              color: Color.fromARGB(255, 99, 148, 182),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              boyut,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ],
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        "Miktar: $miktar",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 183, 89, 89),
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
      ),
    );
  }
}
