import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/user_component/dropdown_selector.dart';

class WorkDetailScreen extends StatefulWidget {
  final String selectedWorkshop;

  const WorkDetailScreen({Key? key, required this.selectedWorkshop})
      : super(key: key);

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  String? _selectedWorkshop;
  String? _collectionName;
  List<String> _workshops = [];
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;


  @override
  void initState() {
    super.initState();
    _selectedWorkshop = widget.selectedWorkshop;
    _fetchWorkshops();
    _fetchCollectionName();
  }

  /// Firestore'dan tüm atölye isimlerini alır ve dropdown için doldurur
  Future<void> _fetchWorkshops() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('atolyeler').get();
      setState(() {
        _workshops = snapshot.docs
            .map((doc) => doc['name'] as String)
            .toList(); // Atölye isimlerini doldur
      });
    } catch (e) {
      print("Atölye listesi alınırken hata oluştu: $e");
    }
  }

  /// Seçilen atölyeye göre ilgili koleksiyon adını alır
  Future<void> _fetchCollectionName() async {
    try {
      if (_selectedWorkshop != null) {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('atolyeler').get();

        for (var doc in snapshot.docs) {
          if (doc['name'] == _selectedWorkshop) {
            setState(() {
              _collectionName = doc['collection'];
            });
            break;
          }
        }
      }
    } catch (e) {
      print("Koleksiyon adı alınırken hata oluştu: $e");
    }
  }

  /// Seçili koleksiyon adından verileri getirir
  Stream<List<Map<String, dynamic>>> _getWorkshopData() async* {
    if (_collectionName != null) {
      yield* FirebaseFirestore.instance
          .collection(_collectionName!)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } else {
      yield [];
    }
  }

  /// Verileri yenilemek için kullanılır
  Future<void> _refreshData() async {
    await _fetchCollectionName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedWorkshop ?? 'Detaylar'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {
                // İleride PDF oluşturma gibi bir özellik eklenecekse buraya yazılabilir
              },
              child: const Icon(Icons.picture_as_pdf),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown ile atölye seçimi
          Row(
            children: [
              Expanded(
                flex: 1,
                child: DropdownSelector(
                  hintText: "Atölye seç",
                  items: _workshops, // Tüm name değerlerini içeren liste
                  selectedValue: _selectedWorkshop,
                  icon: Icons.arrow_drop_down,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedWorkshop = newValue;
                      _fetchCollectionName();
                    });
                  },
                ),
              ),
            ],
          ),
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                searchQuery.value = value;
              },
              decoration: InputDecoration(
                hintText: 'Ara',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Verilerin listelendiği alan
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getWorkshopData(),
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

                  final filteredData = snapshot.data!
                      .where((work) => work['name']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery.value.toLowerCase()))
                      .toList();

                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final data = filteredData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Card'ın kenar köşeleri
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Arka plan rengi
                              borderRadius: BorderRadius.circular(
                                  20), // Container'ın kenar köşeleri
                            ),
                            padding: const EdgeInsets.only(left:16,right: 16,top: 16,bottom: 16),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          'images/toy.webp',
                                          width: 60,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data['urun']}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    const SizedBox(height: 5),
                                    if (data['gramaj'] != null)
                                      Text(
                                        "Gramaj: ${data['gramaj']}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if (data['fine'] != null)
                                      Text(
                                        "Fine: ${data['fine']}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if (data['renk'] != null)
                                      Text(
                                        "Renk: ${data['renk']}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if (data['boyut'] != null)
                                      Text(
                                        "Boyut: ${data['boyut']}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if (data['aksesuar'] != null)
                                      Text(
                                         "Aksesuar: ${data['aksesuar']}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),

                                    const SizedBox(height: 5),
                                    Text(
                                      'Miktar: ${data['miktar']?.toString() ?? '--'}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
