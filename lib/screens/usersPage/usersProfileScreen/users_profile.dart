import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/chatScreen/chat_screen.dart';
import 'package:toyflow/screens/moverScreen/mover_screen.dart';
import 'package:toyflow/screens/usersPage/usersNotificationScreen/users_notification_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/product_services.dart';
import '../../usersWorkScreen/users_work_screen.dart';

class UsersProfileScreen extends StatelessWidget {
  final ProductServices _productService = Get.find();
  final AuthService authService = Get.find<AuthService>();

  // Yeni bir profil resmi değişkeni ekle
  final String profileImagePath;

  UsersProfileScreen({Key? key, required this.profileImagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(profileImagePath), // Profil resmi
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
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 103, 168, 105),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Sohbetler'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatScreen()),
                    );
                    // Bildirimler ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 244, 111, 54),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Bildirimler'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const UsersNotificationScreen()),
                    );
                    // Bildirimler ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 110, 145, 183),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pending_actions,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Bekleyen İşler'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UsersWorkScreen()),
                    );
                    // Bekleyen işler ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 227, 162, 65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Üretim Hareketleri'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MoverScreen()),
                    );
                    // Üretim raporları ekranına yönlendirme
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 222, 108, 100),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Çıkış Yap'),
                  onTap: () {
                    authService.logout();
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
