import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/usersPage/transfer_page/stok_transfer_page.dart';
import 'package:toyflow/services/auth_service.dart';
import '../screens/usersPage/usersProfileScreen/users_profile.dart';
import 'product_services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String workshopName;
  final Widget chatPage;

  const CustomAppBar(
      {super.key, required this.workshopName, required this.chatPage});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Cinsiyet bilgisine göre avatar belirle
  Future<String> _getCinsiyetImagePath(String uid) async {
    final authService = Get.find<AuthService>();
    String cinsiyet = await authService.getUserCins(uid);
    if (cinsiyet == 'Erkek') {
      return 'images/erkek.webp'; // Erkekse erkek resmi
    } else if (cinsiyet == 'Kadın') {
      return 'images/kadin.webp'; // Kadınsa kadın resmi
    } else {
      return ''; // Cinsiyet yoksa varsayılan boş
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final uid =
        authService.currentUser?.uid ?? ''; // Mevcut kullanıcının uid'si

    return AppBar(
      title: FutureBuilder<String>(
        future: _getCinsiyetImagePath(
            uid), // Cinsiyet bilgisine göre resim belirleniyor
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Hata: ${snapshot.error}');
          } else {
            String imagePath = snapshot.data ?? '';

            return Obx(() {
              final productServices = Get.find<ProductServices>();
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
                            : null, // Belirlenen resim varsa, yoksa null
                        backgroundColor:
                            Colors.grey.shade200, // Varsayılan arka plan rengi
                        child: imagePath.isEmpty
                            ? Icon(
                                Icons.person, // Resim yoksa varsayılan ikon
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

        // Eğer workshopName "Paketleme Atölyesi" ise bu ikonu ekle
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
                  Icons.local_shipping, // Ekstra ikon olarak "add" ikonu
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
