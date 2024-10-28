// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/stockPage/stock_add_screen.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            backgroundImage: AssetImage('images/profil.webp'), // Profil resmi
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
              foregroundColor: Colors.black,
              backgroundColor: Colors.grey[200],
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
                  leading: const Icon(Icons.person_add, color: Colors.blue),
                  title: const Text('Kullanıcı Ekle'),
                  subtitle: const Text('Yeni bir kullanıcı ekleyin'),
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
                  leading: const Icon(Icons.inventory, color: Colors.orange),
                  title: const Text('Stok Ekle'),
                  subtitle: const Text('Yeni stok öğesi ekleyin'),
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
                  leading: const Icon(Icons.history, color: Colors.green),
                  title: const Text('Geçmişi Görüntüle'),
                  subtitle: const Text('Tüm işlemlerin geçmişini inceleyin'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Geçmişi görüntüle ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.purple),
                  title: const Text('Ayarları Güncelle'),
                  subtitle: const Text('Yönetici ayarlarını güncelleyin'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Ayarları güncelleme ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.teal),
                  title: const Text('Raporları Görüntüle'),
                  subtitle: const Text('Detaylı raporları görüntüleyin'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Raporları görüntüle ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.logout_rounded, color: Colors.orange),
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
