// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/users/boya_home_screen/boya_services/boya_services.dart';
import 'package:toyflow/screens/users/dika_home_screen/dika_services/dika_services.dart';
import 'package:toyflow/screens/users/dola_home_screen/dola_services/dola_services.dart';
import 'package:toyflow/screens/users/kesa_home_screen/kesa_services/kesa_services.dart';
import 'package:toyflow/screens/users/paka_home_screen/paka_services/paka_services.dart';
import 'package:toyflow/screens/users/user_screen/orders/my_orders/order_preparation.dart';

import '../../../../../services/product_services.dart';
import '../../../../../services/user_services/alert_dialog_service.dart';
import '../../../doka_home_screen/doka_services/doka_services.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductServices productServices = Get.find<ProductServices>();
  final DokaServices dokaServices = DokaServices();
  final BoyaServices boyaServices = BoyaServices();
  final KesaServices kesaServices = KesaServices();
  final DikaServices dikaServices = DikaServices();
  final DolaServices dolaServices = DolaServices();
  final PakaServices pakaServices = PakaServices();

  @override
  void initState() {
    super.initState();
    print(productServices.role.value);
    print("object");
  }

  Future<void> transferOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      showAlertDialog(context, "Sipariş başarıyla stoğa aktarıldı.");
      
    } catch (e) {
      showAlertDialog(context, "Hata $e");
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sipariş başarıyla silindi."),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Hata $e"),
      ));
    }
  }

  Future<void> approveOrder(String orderId) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Tamamlandı'});
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Siparişlerim"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () {
                  Get.to(() => const OrderPreparation());
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (productServices.role.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('orders')
                .where("role", isEqualTo: productServices.role.value)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Sipariş bulunamadı."));
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final orderData = order.data() as Map<String, dynamic>;

                  final status = orderData['status'] ?? 'Bekliyor';
                  final isWaiting = status == 'Bekliyor';

                  return Card(
                    color: Colors.white,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    child: ListTile(
                      title: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Sipariş Detayları",
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
                                  //entry.key != 'role' &&
                                  entry.key != 'status')
                              .map((entry) {
                            return Text("${entry.key}: ${entry.value}");
                          }).toList(),
                          const SizedBox(height: 8),
                          // Status durumu
                          Text(
                            "Durum: $status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == "Bekliyor"
                                  ? Colors.red
                                  : status == "Tamamlandı"
                                      ? Colors.green
                                      : status == "Hazırlanıyor"
                                          ? Colors.orange
                                          : Colors
                                              .grey, // Varsayılan renk (isteğe bağlı)
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status != 'Tamamlandı')
                            IconButton(
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              onPressed: () {
                                approveOrder(order.id);
                              },
                            ),
                          if (status != 'Tamamlandı')
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteOrder(order.id);
                              },
                            ),
                          if (status == 'Tamamlandı')
                            IconButton(
                              icon: const Icon(Icons.transfer_within_a_station,
                                  color: Color.fromARGB(255, 241, 126, 38)),
                              onPressed: () {
                                if (productServices.role.value == "Dokuma") {
                                  dokaServices.addOrUpdateKumasStock(
                                    context: context,
                                    kumas: orderData['urun'],
                                    gramaj: orderData['gramaj'],
                                    fine: orderData['fine'],
                                   miktar: int.tryParse(orderData['miktar'].toString()) ?? 0,

                                  );
                                }
                                if (productServices.role.value == "Boyama") {
                                  boyaServices.addOrUpdateKumasStock(
                                      context: context,
                                      kumas: orderData['urun'],
                                      gramaj: orderData['gramaj'],
                                      fine: orderData['fine'],
                                      miktar: int.tryParse(orderData['miktar'].toString()) ?? 0,

                                      kumasRenk: orderData['renk']);
                                }

                                if (productServices.role.value == "Dikim") {
                                  dikaServices.addOrUpdateUrunStock(
                                      context: context,
                                      urun: orderData['urun'],
                                      miktar: int.tryParse(
                                              orderData['miktar'].toString()) ??
                                          0,
                                      boyut: orderData['boyut'],
                                      urunRenk: orderData['renk']);
                                }
                                deleteOrder(order.id);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }));
  }
}
