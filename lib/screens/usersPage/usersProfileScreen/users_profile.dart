
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/product_services.dart';

class UsersProfileScreen extends StatefulWidget {
  const UsersProfileScreen({super.key});

  @override
  State<UsersProfileScreen> createState() => _UsersProfileScreenState();
}

class _UsersProfileScreenState extends State<UsersProfileScreen> {
  final ProductServices productServices = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Column(
         mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.account_circle,
                    size: 80, // Simgenin boyutu
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${productServices.firstName.string} ${productServices.lastName.string}"),
                    
                    Text(
                          "${productServices.userEmail.string} "),
                  
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}