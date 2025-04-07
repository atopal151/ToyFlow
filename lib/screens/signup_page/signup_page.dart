import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String name = '';
  String surname = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;
  bool isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2)); // Simülasyon

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("İstek Gönderildi"),
          content: const Text(
            "Kayıt isteğiniz başarıyla gönderildi. Onaylandıktan sonra e-posta yoluyla bilgilendirileceksiniz.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendEmail(); // Simüle edilen mail gönderimi
                _clearForm();
              },
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
    }
  }

  void _sendEmail() {
    // Buraya gerçek e-posta servisi entegrasyonu eklenebilir
    print("Mail gönderildi: \nAd: $name\nSoyad: $surname\nEmail: $email\nŞifre: $password");
  }

  void _clearForm() {
    setState(() {
      name = '';
      surname = '';
      email = '';
      password = '';
      confirmPassword = '';
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(
                    hintText: 'Ad',
                    icon: Icons.person,
                    onChanged: (val) => name = val,
                    validator: (val) =>
                        val!.isEmpty ? 'Ad giriniz' : null,
                  ),
                  _buildTextField(
                    hintText: 'Soyad',
                    icon: Icons.person,
                    onChanged: (val) => surname = val,
                    validator: (val) =>
                        val!.isEmpty ? 'Soyad giriniz' : null,
                  ),
                  _buildTextField(
                    hintText: 'Email',
                    icon: Icons.mail,
                    onChanged: (val) => email = val,
                    validator: (val) => val!.isEmpty || !val.contains('@')
                        ? 'Geçerli email giriniz'
                        : null,
                  ),
                  _buildPasswordField(
                    hintText: 'Şifre',
                    onChanged: (val) => password = val,
                    validator: (val) => val!.length < 6
                        ? 'En az 6 karakter giriniz'
                        : null,
                  ),
                  _buildPasswordField(
                    hintText: 'Şifre Tekrar',
                    onChanged: (val) => confirmPassword = val,
                    validator: (val) => val != password
                        ? 'Şifreler uyuşmuyor'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          )
                        : const Text(
                            'Kayıt İsteği Gönder',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
            child: Icon(
              isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
