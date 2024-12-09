// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import 'registerServices/dropdown_style_file.dart';
import 'registerServices/textbox_style_file.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole; // Seçilen rol
  String? _selectedWorkshop; // Seçilen atölye
  String? _selectedCins; // Seçilen Cins

  // Rol ve cinsiyet listeleri
  final List<String> roles = [
    'Dokuma',
    'Boyama',
    'Kesim',
    'Dikim',
    'Dolum',
    'Paketleme',
    'Transfer',
    'Depo'
  ];
  final List<String> cins = ['Erkek', 'Kadın'];

  List<String> workshops = []; // Firestore'dan dinamik olarak gelecek

  // Yüklenme durumu için değişken
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWorkshops(); // Firestore'dan atölye listesini çekiyoruz
  }

  Future<void> _fetchWorkshops() async {
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      // Rol seçilmemişse workshops listesini temizle
      setState(() {
        workshops = [];
      });
      return;
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('atolyeler') // 'atolyeler' koleksiyonu
              .where('nitelik',
                  isEqualTo: _selectedRole) // 'nitelik' alanı rol ile eşleşmeli
              .get();

      List<String> fetchedWorkshops = snapshot.docs
          .map((doc) => doc['name'] as String) // 'name' alanını alıyoruz
          .toList();

      setState(() {
        workshops = fetchedWorkshops; // Listeyi güncelle
        _selectedWorkshop = null; // Yeni liste için seçimi sıfırla
      });
    } catch (e) {
      print('Atölyeler alınırken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Personel Kaydet",
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFieldWithRegister(
              controller: _firstNameController,
              hintText: 'Ad',
              icon: Icons.person,
            ),
            TextFieldWithRegister(
              controller: _lastNameController,
              hintText: 'Soyad',
              icon: Icons.person,
            ),
            TextFieldWithRegister(
              controller: _emailController,
              hintText: 'Email',
              icon: Icons.email,
            ),
            TextFieldWithRegister(
              controller: _passwordController,
              hintText: 'Şifre',
              icon: Icons.lock,
            ),

            // Cinsiyet Dropdown
            DropdownRegisterSelector(
              hintText: 'Cinsiyet Seçin',
              items: cins,
              selectedValue: _selectedCins,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCins = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),

            // Rol Dropdown
            DropdownRegisterSelector(
              hintText: 'Rol Seç',
              items: roles,
              selectedValue: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                  _fetchWorkshops();
                });
              },
              icon: Icons.arrow_drop_down,
            ),

            // Atölye Dropdown
            DropdownRegisterSelector(
              hintText: 'Atölye Seç',
              items: workshops,
              selectedValue: _selectedWorkshop,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWorkshop = newValue;
                });
              },
              icon: Icons.arrow_drop_down,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true; // Yüklenme durumunu başlat
                        });

                        // Kullanıcı kaydetme işlemi
                        await _authService.createUser(
                          _emailController.text,
                          _passwordController.text,
                          _firstNameController.text,
                          _lastNameController.text,
                          _selectedRole ?? '', // Seçilen rolü al
                          _selectedWorkshop ?? '',
                          _selectedCins ?? '', // Seçilen cinsiyeti al
                        );

                        // Kayıt tamamlandığında geri dön
                        Navigator.of(context).pop();

                        setState(() {
                          isLoading = false; // Yüklenme durumunu bitir
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
