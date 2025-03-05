// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/services/user_services/product_services.dart';

class ComingOrders extends StatefulWidget {
  const ComingOrders({super.key});

  @override
  State<ComingOrders> createState() => _ComingOrdersState();
}

class _ComingOrdersState extends State<ComingOrders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductServices productServices = Get.find<ProductServices>();

  final Map<String, String> roleMapping = {
    "admin": "Dokuma",
    "Dokuma": "Boyama",
    "Boyama": "Kesim",
    "Kesim": "Dikim",
    "Dikim": "Dolum",
    "Dolum": "Paketleme",
    "Paketleme": "Transfer",
  };

  @override
  void initState() {
    super.initState();
    productServices.getAtolyeCollectionDetails();
  }

  Future<void> approveOrder(String orderId) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Hazırlanıyor'});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sipariş onaylandı."),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Hata $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = productServices.role.value;
    final targetRole = roleMapping[currentRole];
    print(productServices.getAtolyeCollectionDetails());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelen Siparişler"),
      ),
      body: Obx(
        () {
          final atelyeCollection = productServices.atolyeCollection.value;

          if (atelyeCollection.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, String> roleMapping = {
            "admin": "Dokuma",
            "Dokuma": "Boyama",
            "Boyama": "Kesim",
            "Kesim": "Dikim",
            "Dikim": "Dolum",
            "Dolum": "Paketleme",
            "Paketleme": "Transfer",
          };

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('atelyecollection', isEqualTo: atelyeCollection)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Gelen sipariş yok."));
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final orderData = order.data() as Map<String, dynamic>;

                  final status = orderData['status'] ?? 'Bekliyor';
                  final isWaiting =
                      status == 'Bekliyor' || status == "Hazırlanıyor";

                  if (isWaiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🏷 Başlık
                              const Text(
                                "Bekleyen Siparişler",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                          
                              // 📝 Sipariş Bilgileri
                              ...orderData.entries
                                  .where((entry) =>
                                      entry.value != null &&
                                      entry.value.toString().isNotEmpty &&
                                      entry.key != 'timestamp' &&
                                      entry.key != 'id' &&
                                      entry.key != 'status')
                                  .map((entry) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    "${entry.key}: ${entry.value}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                          
                              // 🔘 Sipariş Durumu
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: status == "Bekliyor"
                                      ? Colors.orange.withOpacity(0.1)
                                      : status == "Hazırlanıyor"
                                          ? Colors.yellow.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Durum: $status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: status == "Bekliyor"
                                        ? Colors.orange
                                        : status == "Hazırlanıyor"
                                            ? Colors.yellow[800]
                                            : Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                          
                              // 🎛️ Butonlar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (status != 'Hazırlanıyor' &&
                                      status != 'Tamamlandı')
                                    _buildActionButton(
                                      icon: Icons.check_circle,
                                      color: Colors.green,
                                      onPressed: () {
                                        approveOrder(order.id);
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              );
            },
          );
        },
      ),
    );
  }

// 🔘 Küçük, yuvarlak buton bileşeni
  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
