// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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

  // Rol ve atölye listeleri
  final List<String> roles = ['Dokuma', 'Kesim', 'Dikim', 'Dolum', 'Paketleme'];
  final List<String> workshops = ['Dokuma Atölyesi', 'Kesim Atölyesi', 'Dikim Atölyesi', 'Dolum Atölyesi', 'Paketleme Atölyesi'];

  // Yüklenme durumu için değişken
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personel Kaydet"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: TextFieldStyles.defaultDecoration('Ad', Icons.person),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _lastNameController,
                decoration: TextFieldStyles.defaultDecoration('Soyad', Icons.person),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _emailController,
                decoration: TextFieldStyles.defaultDecoration('E-posta', Icons.email),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _passwordController,
                decoration: TextFieldStyles.defaultDecoration('Şifre', Icons.lock),
                obscureText: true,
              ),
              const SizedBox(height: 10,),
              // Rol Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text('Rol Seçin'),
                items: roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue; // Seçilen rolü güncelle
                  });
                },
                decoration: TextFieldStyles.defaultDecoration('Rol', Icons.work),
              ),
              const SizedBox(height: 10,),
              // Atölye Dropdown
              DropdownButtonFormField<String>(
                value: _selectedWorkshop,
                hint: const Text('Atölye Seçin'),
                items: workshops.map((String workshop) {
                  return DropdownMenuItem<String>(
                    value: workshop,
                    child: Text(workshop),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWorkshop = newValue; // Seçilen atölyeyi güncelle
                  });
                },
                decoration: TextFieldStyles.defaultDecoration('Atölye', Icons.business),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async { // Buton tıklanabilirliği
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
                      _selectedWorkshop ?? '', // Seçilen atölyeyi al
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const Padding(
                        padding:  EdgeInsets.all(8.0),
                        child:  CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                      )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center, // İkon ve metni ortala
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
      ),
    );
  }
}

class TextFieldStyles {
  static InputDecoration defaultDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(
          color: Colors.grey,
          width: 0.9,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 13,
      ),
    );
  }
}