// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/admin_report_screen/admin_report_screen.dart';
import 'package:toyflow/screens/adminPage/mover_screen/mover_screen.dart';
import 'package:toyflow/screens/adminPage/register_screen/user_info.dart';
import 'package:toyflow/services/user_services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/user_services/product_services.dart';
import '../../users/user_screen/orders/coming_orders/coming_orders.dart';
import '../new_storage_add/storage.dart';
import '../new_toy_add_screen/new_toy_detail.dart';
import '../new_work_shop/work_shop.dart';
import '../stock_screen/stok_screen.dart';

class AdminSettingScreen extends StatefulWidget {
  const AdminSettingScreen({super.key});

  @override
  State<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  final ProductServices _productServices = Get.find();
  final AuthService _authService = Get.find();

  final String privacyPolicyUrl =
      "https://alaettintopal.godaddysites.com/gizlilik-politikasi"; // Buraya kendi gizlilik politikası URL'ni koy

  void _launchURL(String url) async {
  Uri uri = Uri.parse(url); // URL'yi doğru formatta parse et

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Bağlantı açılamıyor: $url');
    throw 'Bağlantı açılamıyor: $url';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('images/erkek.webp'),
          ),
          const SizedBox(height: 10),
          Text(
            "${_productServices.firstName.value} ${_productServices.lastName.value}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            _productServices.userEmail.value,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _launchURL(privacyPolicyUrl);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Gizlilik Politikası'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 185, 147, 123),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_bottom,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Gelen Siparişler'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ComingOrders()),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('Kullanıcı Ekle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const UserInfo());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.report,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('Rapor Al'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const ReportScreen());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.gesture,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('İp Stoğunu Görüntüle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const StockScreen());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('Geçmişi Görüntüle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const MoverScreen());
                  },
                ),
                ListTile( 
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.playlist_add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('Ürün Kalemi'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const NewToyDetail());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('Depo Ekle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const Storage());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.work_history,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('Atölye Ekle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const WorkShop());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 182, 100, 100),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text('Çıkış Yap'),
                  onTap: () async {
                    _authService.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
