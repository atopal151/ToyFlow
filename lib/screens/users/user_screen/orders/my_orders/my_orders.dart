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
  Map<String, bool> isLoading = {};

  @override
  void initState() {
    super.initState();
    productServices.getAtolyeCollectionDetails();
  }

  Future<void> transferOrder(String orderId, int miktar) async {
    try {
      // Geçerli miktar kontrolü
      if (miktar <= 0) {
        if (mounted) {
          showAlertDialog(context, "Geçerli bir miktar girin.");
        }
        return;
      }

      // Siparişi getir
      DocumentSnapshot orderDoc =
          await _firestore.collection('orders').doc(orderId).get();

      print("1.aşama");

      // Firestore'dan gelen miktarı güvenli şekilde int'e çevirme
      String miktarString = orderDoc['miktar']?.toString() ?? "0";
      int currentMiktar = int.tryParse(miktarString) ?? 0;

      print("Mevcut Sipariş Miktarı: $currentMiktar");

      if (!orderDoc.exists) {
        if (mounted) {
          showAlertDialog(context, "Sipariş bulunamadı.");
        }
        return;
      }

      // Geçerli sipariş miktarını aldıktan sonra işlemleri yap
      if (miktar >= currentMiktar) {
        // Eğer transfer miktarı mevcut miktara eşit veya fazla ise siparişi sil
        await _firestore.collection('orders').doc(orderId).delete();
        print("Sipariş tamamen silindi.");

        if (mounted) {
          showAlertDialog(
              context, "Sipariş başarıyla stoğa aktarıldı ve tamamen silindi.");
        }
      } else {
        // Aksi durumda siparişin miktarını güncelle
        int yeniMiktar = currentMiktar - miktar;
        print("Yeni Miktar (Güncellenecek): $yeniMiktar");

        try {
          await _firestore.collection('orders').doc(orderId).update({
            'miktar': yeniMiktar,
          });
          print("Sipariş miktarı Firestore'da başarıyla güncellendi.");
        } catch (updateError) {
          print("Güncelleme hatası: $updateError");
        }

        // Güncellenen dokümanı tekrar al ve yazdır
        DocumentSnapshot updatedDoc =
            await _firestore.collection('orders').doc(orderId).get();
        print("Güncel miktar (Firestore'dan): ${updatedDoc['miktar']}");

        if (mounted) {
          showAlertDialog(context,
              "Sipariş miktarı güncellendi. Kalan miktar: $yeniMiktar");
        }
      }
    } catch (e) {
      if (mounted) {
        showAlertDialog(context, "Hata oluştu: $e");
        print("Hata: $e");
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
          print(productServices.atolyeCollection.value);
          if (productServices.atolyeCollection.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('orders')
                .where("role",
                    isEqualTo: productServices.atolyeCollection.value)
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

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                              "Sipariş Detayları",
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
                                padding: const EdgeInsets.symmetric(vertical: 2),
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
                                    ? Colors.red.withOpacity(0.1)
                                    : status == "Tamamlandı"
                                        ? Colors.green.withOpacity(0.1)
                                        : status == "Hazırlanıyor"
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
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
                            ),
                            const SizedBox(height: 10),
                        
                            // 🎛️ Butonlar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (status != 'Tamamlandı')
                                  _buildActionButton(
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                    onPressed: () async {
                                      setState(() {
                                        isLoading[order.id + '_approve'] = true;
                                      });
                        
                                      await approveOrder(order.id);
                        
                                      setState(() {
                                        isLoading[order.id + '_approve'] = false;
                                      });
                                    },
                                  ),
                                if (status == 'Tamamlandı')
                                  _buildActionButton(
                                    icon: Icons.delete,
                                    color: Colors.red,
                                    onPressed: () async {
                                      setState(() {
                                        isLoading[order.id + '_delete'] = true;
                                      });
                        
                                      await deleteOrder(order.id);
                        
                                      setState(() {
                                        isLoading[order.id + '_delete'] = false;
                                      });
                                    },
                                  ),
                                if (status == 'Tamamlandı')
                                  _buildActionButton(
                                    icon: Icons.transfer_within_a_station,
                                    color:
                                        const Color.fromARGB(255, 241, 126, 38),
                                    onPressed: () async {
                                      setState(() {
                                        isLoading[order.id + '_transfer'] = true;
                                      });
                        
                                      await showAmountInputDialog(
                                          context, order.id, orderData);
                        
                                      setState(() {
                                        isLoading[order.id + '_transfer'] = false;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
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

  Future<void> showAmountInputDialog(BuildContext context, String orderId,
      Map<String, dynamic> orderData) async {
    TextEditingController amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Miktar Girin",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Miktar",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.pie_chart, color: Colors.black),
                      onPressed: () {
                        // Burada ikonun ekstra bir işlevi olacaksa ekleyebilirsin.
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  int miktar = int.tryParse(amountController.text) ?? 0;
                  if (miktar > 0) {
                    transferOrderWithAmount(orderId, orderData, miktar);
                    Navigator.of(context).pop();
                  } else {
                    showAlertDialog(
                        context, "Lütfen geçerli bir miktar girin.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text("Tamam", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> transferOrderWithAmount(
      String orderId, Map<String, dynamic> orderData, int miktar) async {
    try {
      if (productServices.role.value == "Dokuma") {
        String result = await atolyeServices.decreaseOrdersStock(
          collection: orderData['atelyecollection'],
          malzeme: orderData["iplik"],
          context: context,
          denye: orderData['denye'],
          miktar: miktar,
        );
        print(orderData);
        if (result == "başarılı") {
          atolyeServices.addOrUpdateUrunWaitStock(
            collectionsWait: atolyeServices.collectionWait,
            context: context,
            urun: orderData['iplik'],
            denye: orderData['denye'],
            miktar: miktar,
          );

          print(atolyeServices.collectionWait);
          // Siparişi Firestore'dan sil
          await transferOrder(orderId, miktar);
        }
      }
      if (productServices.role.value == "Boyama") {
        String result = await atolyeServices.decreaseOrdersStock(
          collection: orderData['atelyecollection'],
          malzeme: orderData["kumas"],
          context: context,
          gramaj: orderData['gramaj'],
          fine: orderData['fine'],
          renk: orderData['renk'] ?? "Yok",
          miktar: miktar,
        );
        if (result == "başarılı") {
          atolyeServices.addOrUpdateUrunWaitStock(
            collectionsWait: atolyeServices.collectionWait,
            context: context,
            urun: orderData['kumas'],
            gramaj: orderData['gramaj'],
            fine: orderData['fine'],
            renk: orderData['renk'] ?? "Yok",
            miktar: miktar,
          );

          // Siparişi Firestore'dan sil
          await transferOrder(orderId, miktar);
        }
      }
      if (productServices.role.value == "Kesim") {
        String result = await atolyeServices.decreaseOrdersStock(
          collection: orderData['atelyecollection'],
          context: context,
          malzeme: orderData['kumas'],
          gramaj: orderData['gramaj'],
          fine: orderData['fine'],
          miktar: miktar,
          renk: orderData['renk'],
        );
        if (result == "başarılı") {
          atolyeServices.addOrUpdateUrunWaitStock(
            collectionsWait: atolyeServices.collectionWait,
            context: context,
            urun: orderData['kumas'],
            gramaj: orderData['gramaj'],
            fine: orderData['fine'],
            miktar: miktar,
            renk: orderData['renk'],
          );

          // Siparişi Firestore'dan sil
          await transferOrder(orderId, miktar);
        }
      }
      if (productServices.role.value == "Dikim") {
        String result = await atolyeServices.decreaseOrdersStock(
          collection: orderData['atelyecollection'],
          context: context,
          malzeme: orderData['urun'],
          miktar: miktar,
          boyut: orderData['boyut'],
          renk: orderData['renk'],
        );
        if (result == "başarılı") {
          atolyeServices.addOrUpdateUrunWaitStock(
            collectionsWait: atolyeServices.collectionWait,
            context: context,
            urun: orderData['urun'],
            miktar: miktar,
            boyut: orderData['boyut'],
            renk: orderData['renk'],
          );

          // Siparişi Firestore'dan sil
          await transferOrder(orderId, miktar);
        }
      }
      if (productServices.role.value == "Dolum") {
        String result = await atolyeServices.decreaseOrdersStock(
          collection: orderData['atelyecollection'],
          context: context,
          malzeme: orderData['urun'],
          miktar: miktar,
          boyut: orderData['boyut'],
          renk: orderData['renk'],
        );
        if (result == "başarılı") {
          atolyeServices.addOrUpdateUrunWaitStock(
            collectionsWait: atolyeServices.collectionWait,
            context: context,
            urun: orderData['urun'],
            miktar: miktar,
            boyut: orderData['boyut'],
            renk: orderData['renk'],
          );

          // Siparişi Firestore'dan sil
          await transferOrder(orderId, miktar);
        }
      }
      if (productServices.role.value == "Paketleme") {
        String result = await atolyeServices.decreaseOrdersStock(
          collection: orderData['atelyecollection'],
          context: context,
          malzeme: orderData['urun'],
          miktar: miktar,
          boyut: orderData['boyut'],
          renk: orderData['renk'],
        );
        if (result == "başarılı") {
          atolyeServices.addOrUpdateUrunWaitStock(
            collectionsWait: atolyeServices.collectionWait,
            context: context,
            urun: orderData['urun'],
            miktar: miktar,
            boyut: orderData['boyut'],
            renk: orderData['renk'],
          );

          // Siparişi Firestore'dan sil
          await transferOrder(orderId, miktar);
        }
      }
      if (productServices.role.value == "Transfer") {
        String result = await atolyeServices.decreaseOrdersStock(
          collection: orderData['atelyecollection'],
          context: context,
          malzeme: orderData['urun'],
          miktar: miktar,
          boyut: orderData['boyut'],
          aksesuar: orderData['aksesuar'],
          renk: orderData['renk'],
        );
        if (result == "başarılı") {
          atolyeServices.addOrUpdateUrunWaitStock(
            collectionsWait: atolyeServices.collectionWait,
            context: context,
            urun: orderData['urun'],
            miktar: miktar,
            boyut: orderData['boyut'],
            aksesuar: orderData['aksesuar'],
            renk: orderData['renk'],
          );

          // Siparişi Firestore'dan sil
          await transferOrder(orderId, miktar);
          showAlertDialog(context,
              "Sipariş Onaylandı. Paketleme Atölyesi Stoğundan Transfer Yapabilirsiniz.");
        }
      }
    } catch (e) {
      showAlertDialog(context, "Hata: $e");
    }
  }
}
