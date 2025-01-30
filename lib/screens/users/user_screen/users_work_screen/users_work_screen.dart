// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:toyflow/screens/users/atolye_screen/atolye_services/atolye_services.dart';

import '../../../../services/user_services/auth_service.dart';
import '../../../../services/user_services/product_services.dart';

class UsersWorkScreen extends StatefulWidget {
  const UsersWorkScreen({super.key});

  @override
  State<UsersWorkScreen> createState() => _UsersWorkScreenState();
}

class _UsersWorkScreenState extends State<UsersWorkScreen> {
  String? _userRole;
  List<Map<String, dynamic>> _works = [];
  final ProductServices _productServices = Get.find();
  final AuthService _authService = AuthService();
  final AtolyeServices atolyeServices=AtolyeServices();
  bool isLoading = false;
  List<Map<String, String>> fetchedAtolyeler = [];


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _productServices.getAtolyeCollectionDetails();
    print(
        "Product Services Collection: ${_productServices.atolyeCollection.value}");


    await _fetchUserData();
  }
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı oturumu açık değil.")),
      );
      return;
    }

    _userRole = await _authService.getUserRole(user.uid);

    if (_userRole == null || _userRole!.isEmpty) {
      print("Kullanıcı rolü alınamadı.");
      return;
    }

    if (atolyeServices.collectionWait.isEmpty) {
      print("Tablo seçimi yapılmadı.");
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(atolyeServices.collectionWait)
          .get();

      print("${atolyeServices.collectionWait} tablosundaki veriler çekiliyor...");

      setState(() {
        _works = querySnapshot.docs
            .where((doc) => doc['miktar'] != null && doc['miktar'] > 0)
            .map((doc) {
          return {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
        if (atolyeServices.collectionWait.isEmpty) {
          print("Hata: Firestore koleksiyon yolu boş.");
          return;
        }
      });

      print("Tablodan alınan veriler: $_works");
    } catch (e) {
      print("Veriler alınırken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri alınırken hata oluştu: $e")),
      );
    }
  }

  Future<void> transferAndResetStock() async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (atolyeServices.collectionWait.isEmpty) {
      print("Hata: Seçilen koleksiyon boş.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot paketlemeStokSnapshot =
          await firestore.collection(atolyeServices.collectionWait).get();

      for (var doc in paketlemeStokSnapshot.docs) {
        Map<String, dynamic> paketlemeData = doc.data() as Map<String, dynamic>;
        String urunAdi = paketlemeData['urun'];
        String? renk = paketlemeData['renk'];
        String? boyut = paketlemeData['boyut'];
        String? aksesuar = paketlemeData['aksesuar'];
        int adet = paketlemeData['miktar'];
        Timestamp tarih = Timestamp.now();

        if (atolyeServices.collectionWait.isEmpty) {
          print("Hata: Depo koleksiyon yolu boş.");
          setState(() {
            isLoading = false;
          });
          return;
        }

        QuerySnapshot denizliDepoSnapshot = await firestore
            .collection(_productServices.atolyeCollection.value)
            .where('urun', isEqualTo: urunAdi)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .where('aksesuar', isEqualTo: aksesuar)
            .get();

        if (denizliDepoSnapshot.docs.isNotEmpty) {
          var denizliDepoDoc = denizliDepoSnapshot.docs.first;
          int mevcutAdet = denizliDepoDoc['miktar'];
          int yeniAdet = mevcutAdet + adet;

          await firestore
              .collection(atolyeServices.collectionWait)
              .doc(denizliDepoDoc.id)
              .update({
            'miktar': yeniAdet,
            'tarih': tarih,
          });
        } else {
          await firestore
              .collection(atolyeServices.collectionWait)
              .add({
            'urun': urunAdi,
            'renk': renk,
            'boyut': boyut,
            'aksesuar': aksesuar,
            'miktar': adet,
            'tarih': tarih,
          });
        }

        await firestore
            .collection(atolyeServices.collectionWait)
            .doc(doc.id)
            .update({'miktar': 0});
      }
      _fetchUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ürünler Başarıyla Ana Depoya Aktarıldı.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aktarım sırasında hata oluştu: $e')),
      );
      print("Aktarım sırasında hata oluştu: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bekleyen İşler",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          _userRole == "Transfer"
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () async {
                      await transferAndResetStock();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 142, 172, 83),
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.redo,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
         
          const SizedBox(
            height: 20,
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _works.isEmpty
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5000),
                        child: Image.asset(
                          'images/emptymov.webp',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _works.length,
                        itemBuilder: (context, index) {
                          final work = _works[index];
                          String eklemeTarihi = 'Bilinmiyor';

                          if (work['tarih'] != null &&
                              work['tarih'] is Timestamp) {
                            Timestamp timestamp = work['tarih'];
                            DateTime dateTime = timestamp.toDate();
                            eklemeTarihi =
                                DateFormat('dd.MM.yyyy').format(dateTime);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'images/fullmov.webp',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userRole == 'Dokuma' &&
                                                  work['urun'] != null
                                              ? 'Dokunacak ${work['urun']}'
                                              : _userRole == 'Paketleme' &&
                                                      work['urun'] != null
                                                  ? 'Paketlenecek ${work['urun']}'
                                                  : _userRole == 'Boyama' &&
                                                          work['urun'] != null
                                                      ? 'Boyanacak ${work['urun']}'
                                                      : _userRole == 'Dolum' &&
                                                              work['urun'] !=
                                                                  null
                                                          ? 'Doldurulacak ${work['urun']}'
                                                          : _userRole ==
                                                                      'Dikim' &&
                                                                  work['urun'] !=
                                                                      null
                                                              ? 'Dikilecek ${work['urun']}'
                                                              : _userRole ==
                                                                          'Kesim' &&
                                                                      work['urun'] !=
                                                                          null
                                                                  ? 'Kesilecek ${work['urun']}'
                                                                  : _userRole ==
                                                                              'Transfer' &&
                                                                          work['urun'] !=
                                                                              null
                                                                      ? 'Aktarılacak ${work['urun']}'
                                                                      : (work['urun'] ??
                                                                          'Ürün Yok'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (work['gramaj'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.scale,
                                                      color: Color.fromARGB(
                                                          255, 208, 139, 93),
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['gramaj'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                              ),
                                            if (work['fine'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.line_style,
                                                      color: Color.fromARGB(
                                                          255, 91, 166, 204),
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['fine'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                              ),
                                            if (work['denye'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.texture,
                                                      color: Colors.amber,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['denye'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            if (work['renk'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.color_lens,
                                                      color: Colors.amber,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['renk'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              ),
                                            if (work['boyut'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.straighten,
                                                      color: Colors.blueGrey,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${work['boyut']}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.shopping_cart,
                                                color: Colors.blueGrey,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${work['miktar'] ?? 0} Kg/adet',
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                      ),
                    ),
        ],
      ),
    );
  }
}
/*


// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:toyflow/screens/users/atolye_screen/atolye_services/atolye_services.dart';

import '../../../../services/user_component/dropdown_selector.dart';
import '../../../../services/user_services/auth_service.dart';
import '../../../../services/user_services/product_services.dart';

class UsersWorkScreen extends StatefulWidget {
  const UsersWorkScreen({super.key});

  @override
  State<UsersWorkScreen> createState() => _UsersWorkScreenState();
}

class _UsersWorkScreenState extends State<UsersWorkScreen> {
  String? _userRole;
  List<Map<String, dynamic>> _works = [];
  final List<String> _atolye = [];
  String? _oncekiRol;
  String? _selectedAtolye;
  final ProductServices _productServices = Get.find();
  final AuthService _authService = AuthService();
  final AtolyeServices atolyeServices=AtolyeServices();
  bool isLoading = false;
  List<Map<String, String>> fetchedAtolyeler = [];
  String? _selectedAtolyeCollection;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _productServices.getAtolyeCollectionDetails();
    print(
        "Seçilen Atölye Koleksiyonu: ${_productServices.atolyeCollection.value}");
    await fetchOncekiRol();
    print("Seçilen Koleksiyon: $_selectedAtolyeCollection");
    print(
        "Product Services Collection: ${_productServices.atolyeCollection.value}");

    if (_selectedAtolyeCollection == null ||
        _selectedAtolyeCollection!.isEmpty) {
      print("Hata: Koleksiyon bilgisi eksik.");
      return;
    }

    await _fetchUserRoleAndData();
  }

  Future<void> fetchOncekiRol() async {
    try {
      QuerySnapshot connectedSnapshot = await FirebaseFirestore.instance
          .collection('connected_work_shop')
          .where('rol', isEqualTo: _productServices.workshopName.value)
          .get();

      if (connectedSnapshot.docs.isEmpty) {
        print("Belirtilen rol için bağlantı bulunamadı.");
        return;
      }

      _oncekiRol = connectedSnapshot.docs.first['onceki'];

      print("Onceki Rol: $_oncekiRol");

      if (_oncekiRol != null) {
        await fetchAtolyeler(_oncekiRol!);
      }
    } catch (e) {
      print("Onceki rol alınırken hata oluştu: $e");
    }
  }

  Future<void> fetchAtolyeler(String oncekiRol) async {
    try {
      QuerySnapshot atolyelerSnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .where('nitelik', isEqualTo: oncekiRol)
          .get();

      fetchedAtolyeler = atolyelerSnapshot.docs.map((doc) {
        return {
          'name': doc['name'].toString(),
          'collection': doc['collection'].toString(),
        };
      }).toList();

      setState(() {
        _atolye.clear();
        _atolye.addAll(fetchedAtolyeler.map((e) => e['name']!));
        if (_atolye.isNotEmpty) {
          _selectedAtolye = _atolye.first;
          _selectedAtolyeCollection = fetchedAtolyeler.first['collection'];
        }
      });

      print("Fetched Atolyeler: $fetchedAtolyeler");
    } catch (e) {
      print("Atolyeler alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchUserRoleAndData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı oturumu açık değil.")),
      );
      return;
    }

    _userRole = await _authService.getUserRole(user.uid);

    if (_userRole == null || _userRole!.isEmpty) {
      print("Kullanıcı rolü alınamadı.");
      return;
    }

    if (_selectedAtolyeCollection == null ||
        _selectedAtolyeCollection!.isEmpty) {
      print("Tablo seçimi yapılmadı.");
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(_selectedAtolyeCollection!)
          .get();

      print("$_selectedAtolyeCollection tablosundaki veriler çekiliyor...");

      setState(() {
        _works = querySnapshot.docs
            .where((doc) => doc['miktar'] != null && doc['miktar'] > 0)
            .map((doc) {
          return {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
        if (_selectedAtolyeCollection == null ||
            _selectedAtolyeCollection!.isEmpty) {
          print("Hata: Firestore koleksiyon yolu boş.");
          return;
        }
      });

      print("Tablodan alınan veriler: $_works");
    } catch (e) {
      print("Veriler alınırken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri alınırken hata oluştu: $e")),
      );
    }
  }

  Future<void> transferAndResetStock() async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (_selectedAtolyeCollection == null ||
        _selectedAtolyeCollection!.isEmpty) {
      print("Hata: Seçilen koleksiyon boş.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot paketlemeStokSnapshot =
          await firestore.collection(_selectedAtolyeCollection!).get();

      for (var doc in paketlemeStokSnapshot.docs) {
        Map<String, dynamic> paketlemeData = doc.data() as Map<String, dynamic>;
        String urunAdi = paketlemeData['urun'];
        String? renk = paketlemeData['renk'];
        String? boyut = paketlemeData['boyut'];
        String? aksesuar = paketlemeData['aksesuar'];
        int adet = paketlemeData['miktar'];
        Timestamp tarih = Timestamp.now();

        if (_productServices.atolyeCollection.value.isEmpty) {
          print("Hata: Depo koleksiyon yolu boş.");
          setState(() {
            isLoading = false;
          });
          return;
        }

        QuerySnapshot denizliDepoSnapshot = await firestore
            .collection(_productServices.atolyeCollection.value)
            .where('urun', isEqualTo: urunAdi)
            .where('renk', isEqualTo: renk)
            .where('boyut', isEqualTo: boyut)
            .where('aksesuar', isEqualTo: aksesuar)
            .get();

        if (denizliDepoSnapshot.docs.isNotEmpty) {
          var denizliDepoDoc = denizliDepoSnapshot.docs.first;
          int mevcutAdet = denizliDepoDoc['miktar'];
          int yeniAdet = mevcutAdet + adet;

          await firestore
              .collection(_productServices.atolyeCollection.value)
              .doc(denizliDepoDoc.id)
              .update({
            'miktar': yeniAdet,
            'tarih': tarih,
          });
        } else {
          await firestore
              .collection(_productServices.atolyeCollection.value)
              .add({
            'urun': urunAdi,
            'renk': renk,
            'boyut': boyut,
            'aksesuar': aksesuar,
            'miktar': adet,
            'tarih': tarih,
          });
        }

        await firestore
            .collection(_selectedAtolyeCollection!)
            .doc(doc.id)
            .update({'miktar': 0});
      }
      _fetchUserRoleAndData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ürünler Başarıyla Ana Depoya Aktarıldı.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aktarım sırasında hata oluştu: $e')),
      );
      print("Aktarım sırasında hata oluştu: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bekleyen İşler",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          _userRole == "Transfer"
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () async {
                      await transferAndResetStock();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 142, 172, 83),
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.redo,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          DropdownSelector(
            hintText: "Atölye seç",
            items: _atolye,
            selectedValue: _selectedAtolye,
            icon: Icons.arrow_drop_down,
            onChanged: (value) {
              setState(() {
                _selectedAtolye = value;

                _selectedAtolyeCollection = fetchedAtolyeler.firstWhere(
                  (e) => e['name'] == _selectedAtolye,
                  orElse: () => {'collection': "null"},
                )['collection'];
                _fetchUserRoleAndData();
                print("Seçilen Atölye: $_selectedAtolye");
                print("Seçilen Koleksiyon: $_selectedAtolyeCollection");
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _works.isEmpty
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5000),
                        child: Image.asset(
                          'images/emptymov.webp',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _works.length,
                        itemBuilder: (context, index) {
                          final work = _works[index];
                          String eklemeTarihi = 'Bilinmiyor';

                          if (work['tarih'] != null &&
                              work['tarih'] is Timestamp) {
                            Timestamp timestamp = work['tarih'];
                            DateTime dateTime = timestamp.toDate();
                            eklemeTarihi =
                                DateFormat('dd.MM.yyyy').format(dateTime);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'images/fullmov.webp',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userRole == 'Dokuma' &&
                                                  work['urun'] != null
                                              ? 'Dokunacak ${work['urun']}'
                                              : _userRole == 'Paketleme' &&
                                                      work['urun'] != null
                                                  ? 'Paketlenecek ${work['urun']}'
                                                  : _userRole == 'Boyama' &&
                                                          work['urun'] != null
                                                      ? 'Boyanacak ${work['urun']}'
                                                      : _userRole == 'Dolum' &&
                                                              work['urun'] !=
                                                                  null
                                                          ? 'Doldurulacak ${work['urun']}'
                                                          : _userRole ==
                                                                      'Dikim' &&
                                                                  work['urun'] !=
                                                                      null
                                                              ? 'Dikilecek ${work['urun']}'
                                                              : _userRole ==
                                                                          'Kesim' &&
                                                                      work['urun'] !=
                                                                          null
                                                                  ? 'Kesilecek ${work['urun']}'
                                                                  : _userRole ==
                                                                              'Transfer' &&
                                                                          work['urun'] !=
                                                                              null
                                                                      ? 'Aktarılacak ${work['urun']}'
                                                                      : (work['urun'] ??
                                                                          'Ürün Yok'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (work['gramaj'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.scale,
                                                      color: Color.fromARGB(
                                                          255, 208, 139, 93),
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['gramaj'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                              ),
                                            if (work['fine'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.line_style,
                                                      color: Color.fromARGB(
                                                          255, 91, 166, 204),
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['fine'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                              ),
                                            if (work['denye'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.texture,
                                                      color: Colors.amber,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['denye'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            if (work['renk'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.color_lens,
                                                      color: Colors.amber,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    work['renk'] ?? '--',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              ),
                                            if (work['boyut'] != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.straighten,
                                                      color: Colors.blueGrey,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${work['boyut']}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.shopping_cart,
                                                color: Colors.blueGrey,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${work['miktar'] ?? 0} Kg/adet',
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                      ),
                    ),
        ],
      ),
    );
  }
}


 */