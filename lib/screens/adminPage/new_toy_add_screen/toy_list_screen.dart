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
  /// 
  /// 
   
   /// Oyuncak Adını ve Fotoğrafını Güncelle
Future<void> _updateToy(
    String docId, String currentName, String? currentPhoto) async {
  TextEditingController nameController =
      TextEditingController(text: currentName);
  File? newImage;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Center(
        child: Text(
          'Oyuncağı Güncelle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350), // Genişliği sınırladık
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fazladan genişlemeyi engelliyor
          children: [
            // Oyuncak Adı TextField (Yeni Tasarım)
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
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
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Oyuncak Adı',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fotoğraf Seçme Alanı
            GestureDetector(
              onTap: () async {
                newImage = await _pickImage();
                setState(() {});
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 250,
                  height: 150,
                  child: newImage != null
                      ? Image.file(
                          newImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          (currentPhoto != null && currentPhoto.isNotEmpty)
                              ? currentPhoto
                              : _defaultPhotoUrl,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'İptal',
            style: TextStyle(color: Colors.black),
          ),
        ),
        SizedBox(
          width: double.infinity, // Tam genişlikte buton
          child: ElevatedButton(
            onPressed: () async {
              String updatedName = nameController.text.trim();
              String updatedPhotoUrl = currentPhoto ?? _defaultPhotoUrl;

              if (newImage != null) {
                File? compressedImage = await _compressImage(newImage!);
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
                    const SnackBar(content: Text('Fotoğraf sıkıştırılamadı.')),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Güncelle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  /*
  Future<void> _updateToy(
      String docId, String currentName, String? currentPhoto) async {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    File? newImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Center(
          child: Text(
            'Oyuncağı Güncelle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Oyuncak Adı TextField (Yeni Tasarım)
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
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Oyuncak Adı',
                  border: InputBorder.none, // Kenarlık kaldırıldı
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fotoğraf Seçme Alanı
            GestureDetector(
              onTap: () async {
                newImage = await _pickImage();
                setState(() {});
              },
              child: newImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        newImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        (currentPhoto != null && currentPhoto.isNotEmpty)
                            ? currentPhoto
                            : _defaultPhotoUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            child: ElevatedButton(
              onPressed: () async {
                String updatedName = nameController.text.trim();
                String updatedPhotoUrl = currentPhoto ?? _defaultPhotoUrl;

                if (newImage != null) {
                  File? compressedImage = await _compressImage(newImage!);
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
                      const SnackBar(content: Text('Fotoğraf sıkıştırılamadı.')),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Siyah arka plan
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Oval buton
                ),
              ),
              child: const Text(
                'Güncelle',
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
    );
  }*/

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(50)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Get.to(() => const ToyWithPhotoAddScreen()),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
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

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                    children: [
                      // Fotoğraf
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 80, // Kare boyut
                          height: 80,
                          child: Image.network(
                            displayPhoto,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Oyuncak Adı ve Butonlar
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Butonları sağa it
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Ortada hizala
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.black),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      size: 17,
                                    ),
                                    onPressed: () =>
                                        _updateToy(docId, name, photoUrl),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.black),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        size: 17),
                                    onPressed: () => _deleteToy(docId),
                                  ),
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
          );
        },
      ),
    );
  }
}
