// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart'; // Tarih formatı için Intl paketi

class UsersWorkScreen extends StatefulWidget {
  const UsersWorkScreen({super.key});

  @override
  State<UsersWorkScreen> createState() => _UsersWorkScreenState();
}

class _UsersWorkScreenState extends State<UsersWorkScreen> {
  String? _userRole; // Kullanıcının rolü
  List<Map<String, dynamic>> _works = []; // Firestore'dan çekilen işler
  final AuthService _authService = AuthService(); // AuthService örneği

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndData(); // Kullanıcı rolünü al ve verileri yükle
  }

  Future<void> _fetchUserRoleAndData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _userRole = await _authService.getUserRole(user.uid);

      if (_userRole == 'Dokuma') {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('dokuma_work')
            .get();

        setState(() {
          _works = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bu kullanıcı için geçerli bir iş yok.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı oturumu açık değil.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bekleyen İşler"),
        backgroundColor: Colors.white,
      ),
      body: _works.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _works.length,
              itemBuilder: (context, index) {
                final work = _works[index];
                String eklemeTarihi = 'Bilinmiyor';
                
                if (work['tarih'] != null) {
                  Timestamp timestamp = work['tarih'];
                  DateTime dateTime = timestamp.toDate();
                  eklemeTarihi = DateFormat('dd.MM.yyyy').format(dateTime);
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5), // Çerçeve rengi ve kalınlığı
                    borderRadius: BorderRadius.circular(10), // Köşe yuvarlama
                    color: Colors.white, // Arka plan rengi
                  ),
                  child: ListTile(
                    title: Text(work['urun'] ?? 'Ürün Yok', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Renk: ${work['renk'] ?? 'Bilinmiyor'}'),
                        Text('Son Güncelleme Tarihi: $eklemeTarihi',style:const TextStyle(fontSize: 10),),
                      ],
                    ),
                    trailing: Text('Miktar: ${work['miktar'] ?? 0} kg'),
                  ),
                );
              },
            ),
    );
  }
}
