// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/stockPage/stock_add_screen.dart';
import 'package:toyflow/screens/moverScreen/mover_screen.dart';
import 'package:toyflow/services/auth_service.dart';
import '../../../services/product_services.dart';
import '../../registerPage/register_screen.dart';

class AdminSettingScreen extends StatefulWidget {
  const AdminSettingScreen({super.key});

  @override
  State<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  final ProductServices _productServices = Get.find();
  final AuthService _authService=Get.find();

  

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
            backgroundImage: AssetImage('images/erkek.webp'), // Profil resmi
          ),
          const SizedBox(height: 10),
          Text(
            _productServices.firstName.value + _productServices.lastName.value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            _productServices.userEmail.value,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Profili Düzenle'),
          ),
          const SizedBox(height: 30),
          // Ayarlar Listesi
          const SizedBox(height: 30),
          // Menü Seçenekleri
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 111, 178, 131),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 79, 130, 218),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                  title: const Text('Stok Ekle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StockAddScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 196, 137, 107),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MoverScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 178, 165, 82),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_business,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                  title: const Text('Yeni Ürün Kalemi Ekle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Ayarları güncelleme ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 131, 156, 180),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.report,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                  title: const Text('Raporları Görüntüle'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Raporları görüntüle ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading:
                      Container(
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
