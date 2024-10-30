import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../registerPage/registerServices/dropdown_style_file.dart';

class WorkDetailScreen extends StatefulWidget {
  final String selectedWorkshop;

  const WorkDetailScreen({Key? key, required this.selectedWorkshop})
      : super(key: key);

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  String? _selectedWorkshop;
  final List<String> workshops = [
    'Dokuma Atölyesi',
    'Kesim Atölyesi',
    'Dikim Atölyesi',
    'Dolum Atölyesi',
    'Paketleme Atölyesi',
    'Favoriler'
  ];
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _selectedWorkshop = widget.selectedWorkshop;
  }

  Stream<List<Map<String, dynamic>>> getWorkshopData() {
    switch (_selectedWorkshop) {
      case 'Dokuma Atölyesi':
        return FirebaseFirestore.instance
            .collection('dokuma_stok')
            .orderBy('kumas')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'kumas': doc['kumas'],
              'kumas_renk': doc['kumas_renk'],
              'miktar': doc['miktar'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });

      case 'Kesim Atölyesi':
        return FirebaseFirestore.instance
            .collection('kesim_stok')
            .orderBy('urun')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'urun': doc['urun'],
              'kesim_adet': doc['kesim_adet'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });

      case 'Dikim Atölyesi':
        return FirebaseFirestore.instance
            .collection('dikim_stok')
            .orderBy('urun')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'urun': doc['urun'],
              'dikim_adet': doc['dikim_adet'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });

      case 'Dolum Atölyesi':
        return FirebaseFirestore.instance
            .collection('dolum_stok')
            .orderBy('urun')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'urun': doc['urun'],
              'dolum_adet': doc['dolum_adet'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });

      case 'Paketleme Atölyesi':
        return FirebaseFirestore.instance
            .collection('paketleme_stok')
            .orderBy('urun')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'urun': doc['urun'],
              'paket_adet': doc['paket_adet'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });

      default:
        return FirebaseFirestore.instance
            .collection('favoriler')
            .orderBy('urun')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'urun': doc['urun'],
              'favori_adet': doc['favori_adet'],
              'tarih': doc['tarih'],
            };
          }).toList();
        });
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Atölye Seçimi için Dropdown
          Expanded(
            flex: 1,
            child: DropdownRegisterSelector(
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                searchQuery.value = value;
              },
              decoration: InputDecoration(
                hintText: 'Ara',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: getWorkshopData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Veri bulunamadı.'));
                  }

                  return Obx(() {
                    final workshopList = snapshot.data!
                        .where((work) => work['kumas']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.value.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: workshopList.length,
                      itemBuilder: (context, index) {
                        final work = workshopList[index];
                        String eklemeTarihi = 'Bilinmiyor';

                        if (work['tarih'] != null) {
                          Timestamp timestamp = work['tarih'];
                          DateTime dateTime = timestamp.toDate();
                          eklemeTarihi =
                              DateFormat('dd.MM.yyyy').format(dateTime);
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'images/kumas.webp',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          work['kumas'] ?? 'Kumaş Yok',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.color_lens,
                                                color: Color.fromARGB(
                                                    255, 207, 124, 118),
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['kumas_renk'] ?? 'Bilinmiyor'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.layers_sharp,
                                                color: Color.fromARGB(
                                                    255, 81, 124, 146),
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              ' ${work['miktar'] ?? 'Bilinmiyor'} adet',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
