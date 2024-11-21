import 'package:flutter/material.dart';

class ComingOrders extends StatefulWidget {
  const ComingOrders({super.key});

  @override
  State<ComingOrders> createState() => _ComingOrdersState();
}

class _ComingOrdersState extends State<ComingOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Gelen Siparişler"),),);
  }
}