import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ToyWithPhotoAddScreen extends StatefulWidget {
  const ToyWithPhotoAddScreen({super.key});

  @override
  State<ToyWithPhotoAddScreen> createState() => _ToyWithPhotoAddScreenState();
}

class _ToyWithPhotoAddScreenState extends State<ToyWithPhotoAddScreen> {
  final TextEditingController _toyNameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fotoğraf Seçme İşlemi
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);  // XFile'den File'a dönüşüm
      });
      print('Seçilen dosya yolu: ${pickedFile.path}');
    } else {
      print('Hiçbir dosya seçilmedi.');
    }
  }

 Future<File?> compressImage(File file) async {
  // Hedef dosya yolu .jpg uzantılı olarak ayarlanıyor
  final String targetPath = '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

  try {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60, // Sıkıştırma kalitesi
      minWidth: 800,
      minHeight: 800,
    );

    if (result != null) {
      print("Orijinal boyut: ${file.lengthSync()} bytes");
      return File(result.path);  // XFile yerine File döndürüyoruz
    } else {
      print("Sıkıştırma başarısız.");
      return null;
    }
  } catch (e) {
    print("Sıkıştırma hatası: $e");
    return null;
  }
}


  /// Fotoğrafı Firestore'a Kaydetme ve Firestore'a Bilgileri Ekleme
  Future<void> _addToy() async {
    String toyName = _toyNameController.text.trim();

    if (toyName.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fotoğrafı sıkıştır
      File? compressedImage = await compressImage(_selectedImage!);

      if (compressedImage == null) {
        throw Exception("Fotoğraf sıkıştırılamadı.");
      }

      // Firebase Storage instance'ını özel bucket URL'si ile başlat
      FirebaseStorage storage = FirebaseStorage.instanceFor(
               bucket: 'gs://toyflow-9f294.firebasestorage.app', // Doğru bucket URL'si
      );

      // Dosya adını ve referansını belirle
      String fileName = 'toy_photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Yükleme için dosya yolu: $fileName');
      Reference storageRef = storage.ref().child(fileName);

      // Fotoğrafı yükle
      UploadTask uploadTask = storageRef.putFile(compressedImage);

      // Yükleme sırasında loglar
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Yükleme durumu: ${snapshot.state}');
      }, onError: (e) {
        print('Yükleme sırasında hata oluştu: $e');
      });

      // Yükleme tamamlandığında URL'yi al
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      if (taskSnapshot.state == TaskState.success) {
        String downloadUrl = await storageRef.getDownloadURL();
        print('Dosya başarıyla yüklendi. URL: $downloadUrl');

        // Firestore'a oyuncak adı ve fotoğraf linkini ekle
        await _firestore.collection('toy_name').add({
          'name': toyName,
          'photo': downloadUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyuncak başarıyla eklendi.')),
        );

        // Alanları temizle
        setState(() {
          _toyNameController.clear();
          _selectedImage = null;
        });
      } else {
        throw Exception('Yükleme başarısız oldu.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
      print('Yükleme hatası: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _toyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyuncak Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Oyuncak Adı TextField
            TextField(
              controller: _toyNameController,
              decoration: const InputDecoration(
                labelText: 'Oyuncak Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Fotoğraf Seçme Alanı
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text('Fotoğraf Seçmek İçin Tıklayın'),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Yükleme Göstergeci
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addToy,
                    child: const Text('Oyuncak Ekle'),
                  ),
          ],
        ),
      ),
    );
  }
}
