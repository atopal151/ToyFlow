// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/users/atolye_screen/atolye_services/atolye_services.dart';
import 'package:toyflow/screens/users/user_screen/orders/my_orders/order_preparation.dart';

import '../../../../../services/user_services/product_services.dart';
import '../../../../../services/user_component/alert_dialog_service.dart';
import '../../../../adminPage/stock_screen/stock_services/stock_services.dart';
import '../../../transfer_screen/transfer_services/transfer_services.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductServices productServices = Get.find<ProductServices>();
  final StockService stockService = StockService();
  final AtolyeServices atolyeServices = AtolyeServices();
  final TransferServices transferServices = TransferServices();

  @override
  void initState() {
    super.initState();
    print(productServices.role.value);
  }

  Future<void> transferOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      if (mounted) {
        showAlertDialog(context, "Sipariş başarıyla stoğa aktarıldı.");
      }
    } catch (e) {
      if (mounted) {
        showAlertDialog(context, "Hata $e");
      }
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      if (mounted) {
        showAlertDialog(context, "Sipariş başaıyla silindi. ");
      }
    } catch (e) {
      if (mounted) {
        showAlertDialog(context, "Hata $e ");
      }
    }
  }

  Future<void> approveOrder(String orderId) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Tamamlandı'});
      if (mounted) {
        showAlertDialog(context, "Sipariş onaylandı. ");
      }
    } catch (e) {
      if (mounted) {
        showAlertDialog(context, "Hata $e ");
      }
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
      body: Obx(
        () {
          print(productServices.role.value);
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
                    elevation: 3, // Elevation dört taraf için çalışır
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Köşe yumuşatma
                    ),
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
                                  entry.key != 'status')
                              .map((entry) {
                            return Text("${entry.key}: ${entry.value}");
                          }).toList(),
                          const SizedBox(height: 8),
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
                                          : Colors.grey,
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
                          if (status == 'Tamamlandı')
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
                                print(orderData['iplik']);

                                print(orderData['denye']);
                                if (productServices.role.value == "Dokuma") {
                                  stockService.saveStock(
                                    context: context,
                                    urun: orderData['iplik'],
                                    denye: orderData['denye'],
                                    miktar: int.tryParse(
                                            orderData['miktar'].toString()) ??
                                        0,
                                  );
                                }
                                if (productServices.role.value == "Boyama") {
                                  atolyeServices.addOrUpdateUrunStock(
                                    collections: atolyeServices.collectionWait,
                                    context: context,
                                    urun: orderData['kumas'],
                                    gramaj: orderData['gramaj'],
                                    fine: orderData['fine'],
                                    miktar: int.tryParse(
                                            orderData['miktar'].toString()) ??
                                        0,
                                  );
                                }

                                if (productServices.role.value == "Kesim") {
                                  atolyeServices.addOrUpdateUrunStock(

                                    collections: atolyeServices.collectionWait,
                                      context: context,
                                      urun: orderData['kumas'],
                                      gramaj: orderData['gramaj'],
                                      fine: orderData['fine'],
                                      miktar: int.tryParse(
                                              orderData['miktar'].toString()) ??
                                          0,
                                      renk: orderData['renk']);
                                }
                                if (productServices.role.value == "Dikim") {
                                  atolyeServices.addOrUpdateUrunStock(

                                    collections: atolyeServices.collectionWait,
                                      context: context,
                                      urun: orderData['urun'],
                                      miktar: int.tryParse(
                                              orderData['miktar'].toString()) ??
                                          0,
                                      boyut: orderData['boyut'],
                                      renk: orderData['renk']);
                                }
                                if (productServices.role.value == "Dolum") {
                                  atolyeServices.addOrUpdateUrunStock(
                                    collections: atolyeServices.collectionWait,
                                      context: context,
                                      urun: orderData['urun'],
                                      miktar: int.tryParse(
                                              orderData['miktar'].toString()) ??
                                          0,
                                      boyut: orderData['boyut'],
                                      renk: orderData['renk']);
                                }
                                if (productServices.role.value == "Paketleme") {
                                  atolyeServices.addOrUpdateUrunStock(
                                    collections: atolyeServices.collectionWait,
                                      context: context,
                                      urun: orderData['urun'],
                                      miktar: int.tryParse(
                                              orderData['miktar'].toString()) ??
                                          0,
                                      boyut: orderData['boyut'],
                                      renk: orderData['renk']);
                                }
                                if (productServices.role.value == "Transfer") {
                                  atolyeServices.addOrUpdateUrunStock(
                                    collections: atolyeServices.collectionWait,
                                      context: context,
                                      urun: orderData['urun'],
                                      miktar: int.tryParse(
                                              orderData['miktar'].toString()) ??
                                          0,
                                      boyut: orderData['boyut'],
                                      aksesuar: orderData['aksesuar'],
                                      renk: orderData['renk']);
                                  showAlertDialog(context,
                                      "Sipariş Onaylandı Paketleme Atölyesi Stoğundan Transfer Yapabilirsiniz.");
                                }
                                transferOrder(order.id);
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
        },
      ),
    );
  }
}
