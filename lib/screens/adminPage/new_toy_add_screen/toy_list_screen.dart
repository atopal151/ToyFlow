import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:toyflow/screens/adminPage/new_toy_add_screen/new_toy_with_photo_add_screen.dart';

class ToyListScreen extends StatefulWidget {
  const ToyListScreen({super.key});

  @override
  State<ToyListScreen> createState() => _ToyListScreenState();
}

class _ToyListScreenState extends State<ToyListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Storage instance with custom bucket
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://toyflow-9f294.firebasestorage.app',
  );

  /// Varsayılan Fotoğraf URL'si
  final String _defaultPhotoUrl =
      "https://ozguneroyuncak.com/wp-content/uploads/2022/09/site-logo-1-200x76.png";

  /// Fotoğraf Seçme İşlemi
  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Fotoğraf Sıkıştırma İşlemi
  Future<File?> _compressImage(File file) async {
    final String targetPath =
        '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 60,
        minWidth: 800,
        minHeight: 800,
      );

      if (result != null) {
        print("Orijinal boyut: ${file.lengthSync()} bytes");
        return File(result.path);
      } else {
        print("Sıkıştırma başarısız.");
        return null;
      }
    } catch (e) {
      print("Sıkıştırma hatası: $e");
      return null;
    }
  }

  /// Fotoğrafı Firebase Storage'a Yükle
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName =
          'toy_photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Fotoğraf yükleme hatası: $e');
      return null;
    }
  }

  /// Oyuncak Adını ve Fotoğrafını Güncelle
  Future<void> _updateToy(
      String docId, String currentName, String? currentPhoto) async {
    TextEditingController _nameController =
        TextEditingController(text: currentName);
    File? _newImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oyuncağı Güncelle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Oyuncak Adı'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  _newImage = await _pickImage();
                  setState(() {});
                },
                child: _newImage != null
                    ? Image.file(_newImage!, height: 150, fit: BoxFit.cover)
                    : Image.network(
                        (currentPhoto != null && currentPhoto.isNotEmpty)
                            ? currentPhoto
                            : _defaultPhotoUrl,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              String updatedName = _nameController.text.trim();
              String updatedPhotoUrl = currentPhoto ?? _defaultPhotoUrl;

              if (_newImage != null) {
                // Fotoğrafı sıkıştır
                File? compressedImage = await _compressImage(_newImage!);
                if (compressedImage != null) {
                  String? uploadedUrl = await _uploadImage(compressedImage);
                  if (uploadedUrl != null) {
                    updatedPhotoUrl = uploadedUrl;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Yeni fotoğraf yüklenemedi.')),
                    );
                    return;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Fotoğraf sıkıştırılamadı.')),
                  );
                  return;
                }
              }

              await _firestore.collection('toy_name').doc(docId).update({
                'name': updatedName,
                'photo': updatedPhotoUrl,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Oyuncak güncellendi.')),
              );

              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  /// Oyuncağı Sil
  Future<void> _deleteToy(String docId) async {
    await _firestore.collection('toy_name').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oyuncak silindi.')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text('Oyuncak Listesi'),
        actions: [
          InkWell(
            onTap: () => Get.to(() => const ToyWithPhotoAddScreen()),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('toy_name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Hiç oyuncak eklenmemiş.'));
          }

          final toys = snapshot.data!.docs;

          return ListView.builder(
            itemCount: toys.length,
            itemBuilder: (context, index) {
              var toy = toys[index];
              String docId = toy.id;
              String name = toy['name'] ?? 'İsimsiz';
              String? photoUrl = toy['photo'];

              String displayPhoto = (photoUrl != null && photoUrl.isNotEmpty)
                  ? photoUrl
                  : _defaultPhotoUrl;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      displayPhoto,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 57, 50, 50)),
                        onPressed: () => _updateToy(docId, name, photoUrl),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color.fromARGB(255, 203, 105, 98)),
                        onPressed: () => _deleteToy(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
