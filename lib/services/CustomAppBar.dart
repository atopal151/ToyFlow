// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/chatScreen/chatScreen.dart';
import 'package:toyflow/screens/usersPage/usersNotificationScreen/usersNotificationScreen.dart';
import 'package:toyflow/screens/usersPage/usersProfileScreen/UsersProfileScreen.dart';
import 'package:toyflow/services/auth_service.dart';

import '../screens/usersWorkScreen/UsersWorkScreen.dart';
import 'product_services.dart'; // Obx için gerekli

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String workshopName;
  final Widget chatPage; 

  CustomAppBar({required this.workshopName, required this.chatPage});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // productServices Obx widget'ında kullanılıyor
    final productServices =
        Get.find<ProductServices>(); // Obx ile dinamik veri takibi
    final authService = Get.find<AuthService>();
    return AppBar(
      title: Obx(
        () => Row(
          children: [
            InkWell(
              onTap:() {
                Navigator.push(context,MaterialPageRoute(builder: ((context) => const UsersProfileScreen())));
              },
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 25,
                child: Icon(
                  Icons.account_circle,
                  size: 35,
                  color: Colors.black87,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${productServices.firstName.value} ${productServices.lastName.value}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  workshopName, // Burada dışarıdan gelen atölye ismini gösteriyoruz
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          color: Colors.white,
          onSelected: (value) {
            print('$value seçildi');
          },
          offset: const Offset(0, 50), // Menü, AppBar'ın altından açılacak
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'Bildirimler',
                child: InkWell(
                  onTap: () {
                     Navigator.push(context,MaterialPageRoute(builder: ((context) => const UsersNotificationScreen())));
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_none_outlined,
                          color: Colors.black),
                      SizedBox(width: 10),
                      Text('Bildirimler'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'Bekleyen İşler',
                child: InkWell(
                  onTap: () {
                     Navigator.push(context,MaterialPageRoute(builder: ((context) => const UsersWorkScreen())));
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Bekleyen İşler'),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'Çıkış',
                child: InkWell(
                  onTap: () {
                    authService.logout();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.logout_outlined, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Çıkış Yap'),
                    ],
                  ),
                ),
              ),
            ];
          },
        ),
        const SizedBox(
          width: 5,
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  const ChatScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 15,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                   Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  chatPage),
                );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.edit,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
