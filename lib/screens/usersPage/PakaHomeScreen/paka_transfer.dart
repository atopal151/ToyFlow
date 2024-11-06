import 'package:flutter/material.dart';

class PakaTransfer extends StatefulWidget {
  const PakaTransfer({super.key});

  @override
  State<PakaTransfer> createState() => _PakaTransferState();
}

class _PakaTransferState extends State<PakaTransfer> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: AppBar(title: const Text("Transfer Ekranı"),),);
  }
}