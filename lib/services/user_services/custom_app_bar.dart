import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/users/transfer_screen/stok_sell_screen.dart';
import 'package:toyflow/screens/users/transfer_screen/stok_transfer_screen.dart';
import 'package:toyflow/services/user_services/auth_service.dart';
import '../../screens/users/user_screen/users_profile_screen/users_profile_screen.dart';
import 'product_services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String workshopName;
  final Widget chatPage;

  const CustomAppBar(
      {super.key, required this.workshopName, required this.chatPage});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
 
  Future<String> _getCinsiyetImagePath(String uid) async {
    final authService = Get.find<AuthService>();
    String cinsiyet = await authService.getUserCins(uid);
    if (cinsiyet == 'Erkek') {
      return 'images/erkek.webp';  
    } else if (cinsiyet == 'Kadın') {
      return 'images/kadin.webp';  
    } else {
      return '';  
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final uid =
        authService.currentUser?.uid ?? '';  

    return AppBar(
      title: FutureBuilder<String>(
        future: _getCinsiyetImagePath(
            uid),  
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Hata: ${snapshot.error}');
          } else {
            String imagePath = snapshot.data ?? '';

            return Obx(() {
              final productServices = Get.find<ProductServices>();
              print(productServices.workshopName.value);
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UsersProfileScreen(
                                      profileImagePath: imagePath,
                                    )));
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: imagePath.isNotEmpty
                            ? AssetImage(imagePath)
                            : null,  
                        backgroundColor:
                            Colors.grey.shade200,  
                        child: imagePath.isEmpty
                            ? Icon(
                                Icons.person,  
                                size: 35,
                                color: Colors.grey.shade900,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${productServices.firstName.value} ${productServices.lastName.value}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        workshopName,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              );
            });
          }
        },
      ),
      actions: [
        if (workshopName != "Transfer Birimi")
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => chatPage),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 0.5,
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
 
        if (workshopName == "Transfer Birimi")
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Get.to(()=>const StokTransfer());
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.local_shipping,  
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
 
        if (workshopName == "Transfer Birimi")
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Get.to(()=>const StockSellScreen());
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.sell,  
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
