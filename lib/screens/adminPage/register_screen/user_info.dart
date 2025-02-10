import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/register_screen/register_screen.dart';

import '../../../services/user_component/cutom_loading_button.dart';
import 'registerServices/dropdown_style_file.dart';



class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedRole;
  String? _selectedWorkshop;
  bool _isActive = true;
  bool _isLoadingWorkshops = false;
  final List<String> roles = [
    'admin',
    'Dokuma',
    'Boyama',
    'Kesim',
    'Dikim',
    'Dolum',
    'Paketleme',
    'Transfer',
    'Depo'
  ];
  List<String> workshops = [];

Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      debugPrint("Firestore'dan kullanıcı silindi: $userId");
    } catch (e) {
      debugPrint("Kullanıcı silinirken hata oluştu: $e");
    }
  }

Future<bool?> _showConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dikkat!"),
        content: const Text("Kullanıcıyı silmek istediğinizden emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Evet, Sil")),
        ],
      ),
    );
  }


  Future<void> _fetchWorkshops(String? role) async {
    setState(() {
      _isLoadingWorkshops = true;
    });

    if (role == null || role == 'admin') {
      setState(() {
        workshops = ['admin'];
        _selectedWorkshop = 'admin';
        _isLoadingWorkshops = false;
      });
      return;
    }

    try {
      var snapshot = await _firestore
          .collection('atolyeler')
          .where('nitelik', isEqualTo: role)
          .get();
      List<String> fetchedWorkshops =
          snapshot.docs.map((doc) => doc['name'] as String).toSet().toList();

      setState(() {
        workshops = fetchedWorkshops;
        if (_selectedWorkshop == null ||
            !workshops.contains(_selectedWorkshop)) {
          _selectedWorkshop = workshops.isNotEmpty ? workshops.first : null;
        }
      });
    } catch (e) {
      debugPrint("Atölye verileri alınırken hata oluştu: $e");
    } finally {
      setState(() {
        _isLoadingWorkshops = false;
      });
    }
  }

  void _showUserDetailsBottomSheet(DocumentSnapshot userDoc) async {
    setState(() {
      _selectedRole = userDoc['role'];
      _selectedWorkshop =
          userDoc['role'] == 'admin' ? 'admin' : userDoc['workshop'];
      _isActive = userDoc['isActive'] ?? true;
      workshops = [];
    });

    await _fetchWorkshops(_selectedRole);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${userDoc['firstName']} ${userDoc['lastName']}",
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    DropdownRegisterSelector(
                      hintText: 'Rol Seç',
                      items: roles,
                      selectedValue: _selectedRole,
                      icon: Icons.person,
                      onChanged: (String? newValue) async {
                        setState(() {
                          _selectedRole = newValue;
                          _selectedWorkshop = null;
                          workshops = [];
                          _isLoadingWorkshops = true;
                        });

                        await _fetchWorkshops(newValue);

                        setState(() {
                          _isLoadingWorkshops = false;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    _isLoadingWorkshops
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownRegisterSelector(
                            hintText: 'Atölye Seç',
                            items: workshops,
                            selectedValue: _selectedWorkshop,
                            icon: Icons.factory,
                            onChanged: _selectedRole == 'admin'
                                ? (_) {} 
                                : (String? newValue) {
                                    setState(() {
                                      _selectedWorkshop = newValue;
                                    });
                                  },
                          ),

                    const SizedBox(height: 10),

                    SwitchListTile(
                      activeTrackColor: Colors.black,
                      selectedTileColor: Colors.white,
                      title: const Text("Kullanıcı Aktif Mi?"),
                      value: _isActive,
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.black, 
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("İptal"),
                        ),
                        TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () async {
                          bool? confirmDelete = await _showConfirmDialog(context);
                          if (confirmDelete == true) {
                            await _deleteUser(userDoc.id);
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Sil"),
                      ),
                        CustomLoadingButton(
                          onPressed: () async {
                            _firestore
                                .collection('users')
                                .doc(userDoc.id)
                                .update({
                              'workshop': _selectedWorkshop,
                              'role': _selectedRole,
                              'isActive': _isActive,
                            });
                            Navigator.pop(context);
                          },
                          text: "Güncelle",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcılar"),
      actions: [
        InkWell(
            onTap: () {
              Get.to(() => const RegisterScreen());
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          )
      ],),
      
      body: StreamBuilder(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return Padding(
                padding: const EdgeInsets.only(left:5.0,right: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 40,
                    backgroundImage: user["cins"] == "Erkek"
                        ? const AssetImage('images/erkek.webp')
                        : const AssetImage('images/kadin.webp'),
                  ),
                  title: Text(
                    "${user['firstName']} ${user['lastName']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    "Atölye: ${user['role'] == 'admin' ? 'admin' : user['workshop']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    user['isActive'] == true ? Icons.check_circle : Icons.cancel,
                    color: user['isActive'] == true ? Colors.green : Colors.red,
                  ),
                  onTap: () => _showUserDetailsBottomSheet(user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
