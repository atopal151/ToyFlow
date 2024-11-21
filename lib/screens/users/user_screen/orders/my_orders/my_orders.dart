import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/users/user_screen/orders/my_orders/order_preparation.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Siparişlerim"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:16.0),
            child: InkWell(
              onTap: () {
                Get.to(()=>const OrderPreparation());
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10.0),
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: const Center(child: Text("data"),),
    );
  }
}
