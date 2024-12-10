import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/chat_screen/chat_screen.dart';
import 'package:toyflow/screens/users/user_screen/orders/coming_orders/coming_orders.dart';
import 'package:toyflow/screens/users/user_screen/orders/my_orders/my_orders.dart';
import 'package:toyflow/screens/users/user_screen/users_notification_screen/users_notification_screen.dart';
import '../../../../services/user_services/auth_service.dart';
import '../../../../services/user_services/product_services.dart';
import '../users_work_screen/users_work_screen.dart';
import '../waste/waste_flow.dart';

class UsersProfileScreen extends StatefulWidget {
  final String profileImagePath;

  // ignore: prefer_const_constructors_in_immutables
  UsersProfileScreen({Key? key, required this.profileImagePath})
      : super(key: key);

  @override
  State<UsersProfileScreen> createState() => _UsersProfileScreenState();
}

class _UsersProfileScreenState extends State<UsersProfileScreen> {
  final ProductServices _productService = Get.find();

  final AuthService authService = Get.find<AuthService>();

  String? _userRole;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();  
  }

  Future<void> _fetchUserRole() async {
    if (user != null) {
      _userRole = await authService.getUserRole(user!.uid);
      setState(() {});  
    }
  }

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
          CircleAvatar(
            radius: 40,
            backgroundImage:
                AssetImage(widget.profileImagePath),  
          ),
          const SizedBox(height: 10),
          Text(
            "${_productService.firstName.value} ${_productService.lastName.value}",
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
          Expanded(
            child: ListView(
              children: [
                if(_productService.role.value!="Transfer")
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
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 119, 119, 118),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: const Text('Siparişlerim'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyOrders()),
                    ); 
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 119, 119, 118),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pending_actions,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(_userRole != "Transfer"
                      ? 'Bekleyen İşler'
                      : 'Sevk Edilecek Stok'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersWorkScreen(),
                      ),
                    ); 
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 119, 119, 118),
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
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 119, 119, 118),
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
                  },
                ),
                if (_userRole != null && _userRole != "Transfer")
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 119, 119, 118),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    title: const Text('Firelerim'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FireTakip()),
                      ); 
                    },
                  ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 195, 99, 99),
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
