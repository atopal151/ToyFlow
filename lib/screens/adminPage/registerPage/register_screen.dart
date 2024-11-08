// ignore_for_file: use_build_context_synchronously

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

  // Rol ve atölye listeleri
  final List<String> roles = ['Dokuma', 'Kesim', 'Dikim', 'Dolum', 'Paketleme','Transfer'];
  final List<String> workshops = [
    'Dokuma Atölyesi',
    'Kesim Atölyesi',
    'Dikim Atölyesi',
    'Dolum Atölyesi',
    'Paketleme Atölyesi',
    'Transfer Birimi'
  ];
  final List<String> cins = ['Erkek', 'Kadın'];

  // Yüklenme durumu için değişken
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personel Kaydet"),
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

            // cinsiyet Dropdown
            DropdownRegisterSelector(
              hintText: 'Cinsiyet Seçin',
              items: cins,
              selectedValue: _selectedCins,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCins = newValue;
                });
              },
              icon: Icons.transgender,
            ),

            // rol Dropdown
          DropdownRegisterSelector(
              hintText: 'Rol Seç',
              items: roles,
              selectedValue: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
              icon: Icons.work,
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
              icon: Icons.cut,
            ),
           
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Buton tıklanabilirliği
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
                            _selectedCins ?? '' // Seçilen cinsiyeti al
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
                        mainAxisAlignment:
                            MainAxisAlignment.center, // İkon ve metni ortala
                        children: [
                          Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Yazı rengi
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