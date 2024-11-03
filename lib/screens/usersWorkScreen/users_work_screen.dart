// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class UsersWorkScreen extends StatefulWidget {
  const UsersWorkScreen({super.key});

  @override
  State<UsersWorkScreen> createState() => _UsersWorkScreenState();
}

class _UsersWorkScreenState extends State<UsersWorkScreen> {
  String? _userRole;
  List<Map<String, dynamic>> _works = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndData();
  }

  Future<void> _fetchUserRoleAndData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _userRole = await _authService.getUserRole(user.uid);

      if (_userRole == 'Dokuma') {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('dokuma_work').get();

        setState(() {
          _works = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();
        });
      } else if (_userRole == 'Kesim') {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('dokuma_stok').get();

        setState(() {
          _works = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();
        });
      } else if (_userRole == 'Dikim') {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('kesim_stok').get();

        setState(() {
          _works = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();
        });
      } else if (_userRole == 'Dolum') {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('dikim_stok').get();

        setState(() {
          _works = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();
        });
      } else if (_userRole == 'Paketleme') {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('dolum_stok').get();

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
          const SnackBar(
              content: Text("Bu kullanıcı için geçerli bir iş yok.")),
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
      appBar: AppBar(
        title: const Text("Bekleyen İşler"),
        elevation: 0,
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

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sol tarafta görsel
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'images/dolum.webp', // Görsel dosyanızın yolu
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Orta kısımda ürün bilgisi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                work['urun'] ?? 'Ürün Yok',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.color_lens,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    work['renk'] ?? 'Bilinmiyor',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.layers,
                                      color: Colors.blueGrey, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${work['miktar'] ?? 0} Kg/adet',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                   const SizedBox(width: 10),
                                  const Icon(Icons.straighten,
                                      color: Colors.blueGrey, size: 16),
                                  const SizedBox(width: 4),
                                  if (work['boyut'] != null)
                                    Text(
                                      "${work['boyut']} cm",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
