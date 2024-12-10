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
  };

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelen Siparişler"),
      ),
      body: Obx(
        () {
          final currentRole = productServices.role.value;

          if (currentRole.isEmpty) {
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

          final targetRole = roleMapping[currentRole];

          if (targetRole == null) {
            return const Center(child: Text("Geçersiz role."));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('role', isEqualTo: targetRole)
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
                  final isWaiting = status == 'Bekliyor';
                  if (status == 'Bekliyor' || status == "Hazırlanıyor") {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 3,
                      child: ListTile(
                        title: const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Bekleyen Siparişler",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...orderData.entries
                                .where((entry) =>
                                    entry.value != null &&
                                    entry.value.toString().isNotEmpty &&
                                    entry.key != 'timestamp' &&
                                    entry.key != 'id' &&
                                    entry.key != 'status')
                                .map((entry) {
                              return Text("${entry.key}: ${entry.value}");
                            }).toList(),
                            const SizedBox(height: 8),
                            Text(
                              "Durum: $status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isWaiting ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status != 'Hazırlanıyor' &&
                                status != 'Tamamlandı')
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  approveOrder(order.id);
                                },
                              ),
                          ],
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
}
