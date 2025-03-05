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
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<File?> compressImage(File file) async {
    final String targetPath = '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 60,
        minWidth: 800,
        minHeight: 800,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
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
      File? compressedImage = await compressImage(_selectedImage!);
      if (compressedImage == null) throw Exception("Fotoğraf sıkıştırılamadı.");

      FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'gs://toyflow-9f294.firebasestorage.app',
      );

      String fileName = 'toy_photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = storage.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(compressedImage);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      if (taskSnapshot.state == TaskState.success) {
        String downloadUrl = await storageRef.getDownloadURL();

        await _firestore.collection('toy_name').add({
          'name': toyName,
          'photo': downloadUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyuncak başarıyla eklendi.')),
        );

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
            // Oyuncak Adı TextField (Düzenlenmiş Tasarım)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Oval kenarlar
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _toyNameController,
                decoration: const InputDecoration(
                  hintText: 'Oyuncak ismi yazın...',
                  border: InputBorder.none, // Kenarlık kaldırıldı
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fotoğraf Seçme Alanı
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text('Fotoğraf Seçmek İçin Tıklayın'),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Yükleme Göstergeci
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addToy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Siyah arka plan
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Oval buton
                        ),
                      ),
                      child: const Text(
                        'Oyuncak Ekle',
                        style: TextStyle(
                          color: Colors.white, // Beyaz metin
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
