import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/usersPage/dokaHomeScreen/doka_mover_screen.dart';
import '../../../services/product_services.dart';

// ignore: use_key_in_widget_constructors
class UsersProfileScreen extends StatelessWidget {
  final ProductServices _productService = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profilim',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Profil Resmi ve Kullanıcı Bilgisi
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('images/profil.webp'), // Profil resmi
          ),
          const SizedBox(height: 10),
          Text(
            _productService.firstName.value + _productService.lastName.value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
           Text(
            _productService.userEmail.value,
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
          Expanded(
            child: ListView(
  children: [
    ListTile(
      leading: const Icon(Icons.inventory, color: Colors.blue),
      title: const Text('Stok Durumu'),
      subtitle: const Text('Atölyenizin mevcut stok miktarlarını kontrol edin'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Stok durumu ekranına yönlendirme
      },
    ),
    ListTile(
      leading: const Icon(Icons.pending_actions, color: Colors.orange),
      title: const Text('Bekleyen İşler'),
      subtitle: const Text('Tamamlanması gereken işleri görüntüleyin'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Bekleyen işler ekranına yönlendirme
      },
    ),
    ListTile(
      leading: const Icon(Icons.history, color: Colors.green),
      title: const Text('Üretim Geçmişi'),
      subtitle: const Text('Tamamlanan işlerin geçmişini inceleyin'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Üretim geçmişi ekranına yönlendirme
      },
    ),
    ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.purple),
      title: const Text('İş Planını Güncelle'),
      subtitle: const Text('Güncel iş planınızı ayarlayın'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // İş planı güncelleme ekranına yönlendirme
      },
    ),
    ListTile(
      leading: const Icon(Icons.history, color: Colors.teal),
      title: const Text('Üretim Hareketleri'),
      subtitle: const Text('Üretim hareketlerinizi görüntüleyin'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
         Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>
                                const DokaMoverScreen())));
        // Üretim raporları ekranına yönlendirme
      },
    ),
  ],
)

          ),
        ],
      ),
     
    );
  }
}
