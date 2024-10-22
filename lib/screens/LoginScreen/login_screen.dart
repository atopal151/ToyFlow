// ignore_for_file: file_names
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İkonun eklenmesi
              Image.asset(
                'images/iconozgn.png', // 'images' yerine 'assets' klasörünü kullandığını varsaydım
                width: 100.0,
                height: 100.0,
              ),
              const SizedBox(height: 40.0),

              // Kullanıcı adı TextField
              Container(
                width: 320.0, // Çerçevenin genişliği
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Çerçevenin iç rengi
                  borderRadius:
                      BorderRadius.circular(20.0), // Köşeleri yuvarlatmak için
                  border: Border.all(
                    color: Colors.grey, // Çerçeve rengi
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const TextField(
                      decoration: InputDecoration(
                        // Normal durumdaki kenarlık
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey, // Kenar rengi pembe
                            width: 0.5,
                          ),
                        ),
                        // Odaklanıldığında (tıklandığında) kenarlık
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors
                                .black, // Odaklanıldığında kenar rengi pembe
                            width: 0.5,
                          ),
                        ),
                        labelText: 'Kullanıcı Adı',
                        labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13 // Label rengi pembe
                            ),

                      ),
                    ),

                    const SizedBox(height: 20.0),
                    // Şifre TextField
                    const TextField(
                      obscureText: true, // Şifre alanı gizli olsun
                      decoration: InputDecoration(
                        // Normal durumdaki kenarlık
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey, // Kenar rengi pembe olacak
                            width: 0.5,
                          ),
                        ),
                        // Odaklanıldığında kenarlık
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.black, // Odaklanıldığında da pembe
                            width: 0.5,
                          ),
                        ),
                        labelText: 'Şifre',
                        labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13 // Label rengi pembe olacak
                            ),
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // Giriş yap butonu
                    ElevatedButton(
                      onPressed: () {
                        // Giriş yapma işlevi burada olacak
                      },
                      style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF9FCE4D), // #9FCE4D rengi

                        minimumSize: const Size(
                            double.infinity, 50.0), // Buton genişliği tam olsun
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: Colors.white, // Yazı rengi beyaz olacak
                          fontWeight: FontWeight
                              .bold, // Yazıyı kalın yap (isteğe bağlı)
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
