import 'package:flutter/material.dart';

import '../../../services/custom_app_bar.dart';
import '../PakaHomeScreen/paka_edit_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        workshopName: "Transfer Birimi",
        chatPage: PakaEditScreen(),
      ),
    );
  }
}
