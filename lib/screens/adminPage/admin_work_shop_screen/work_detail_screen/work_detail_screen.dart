import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/user_component/dropdown_selector.dart';
import '../../../../services/user_services/pdf_services.dart';

class WorkDetailScreen extends StatefulWidget {
  final String selectedWorkshop;

  const WorkDetailScreen({super.key, required this.selectedWorkshop});

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedWorkshop;
  String? _collectionName;
  List<String> _workshops = [];
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  String? role;

  @override
  void initState() {
    super.initState();
    _selectedWorkshop = widget.selectedWorkshop;
    _fetchWorkshops();
    _fetchCollectionName();
  }

  String selectedFilter = 'Hazır Ürünler';

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: selectedFilter,
      borderRadius: BorderRadius.circular(20),
      iconEnabledColor: Colors.white,
      dropdownColor: Colors.black,
      style: TextStyle(color: Colors.white),
      onChanged: (String? newValue) {
        setState(() {
          selectedFilter = newValue!;
          if (selectedFilter == 'Hazır Ürünler') {
            _fetchCollectionName();
          } else {
            _fetchCollectionWait();
          }
        });
      },
      items: <String>['Hazır Ürünler', 'Bekleyen Ürünler']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Future<void> _generatePdf() async {
    final snapshot = await _firestore
        .collection(_collectionName!)
        .where("miktar", isNotEqualTo: 0)
        .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();

    // ignore: use_build_context_synchronously
    await PdfService.generatePdf(context, _selectedWorkshop!, data);
  }

  Future<void> _fetchWorkshops() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('atolyeler').get();
      setState(() {
        _workshops = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print("Atölye listesi alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchCollectionName() async {
    try {
      if (_selectedWorkshop != null) {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('atolyeler').get();

        for (var doc in snapshot.docs) {
          if (doc['name'] == _selectedWorkshop) {
            setState(() {
              _collectionName = doc['collection'];
              role = doc["nitelik"];
              print(role);
            });
            break;
          }
        }
      }
    } catch (e) {
      print("Koleksiyon adı alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchCollectionWait() async {
    try {
      if (_selectedWorkshop != null) {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('atolyeler').get();

        for (var doc in snapshot.docs) {
          if (doc['name'] == _selectedWorkshop) {
            setState(() {
              _collectionName = doc['collectionWait'];
              role = doc["nitelik"];
              print(role);
            });
            break;
          }
        }
      }
    } catch (e) {
      print("Koleksiyon adı alınırken hata oluştu: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> _getWorkshopData() async* {
    if (_collectionName != null) {
      yield* FirebaseFirestore.instance
          .collection(_collectionName!)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .where((data) =>
                  (data['miktar'] ?? 0) >
                  0) // Miktarı 0'dan büyük olanları filtrele
              .toList());
    } else {
      yield [];
    }
  }

  Future<void> _refreshData() async {
    await _fetchCollectionName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedWorkshop ?? 'Detaylar',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {
                _generatePdf();
              },
              child: const Icon(Icons.picture_as_pdf),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: DropdownSelector(
                  hintText: "Atölye seç",
                  items: _workshops,
                  selectedValue: _selectedWorkshop,
                  icon: Icons.arrow_drop_down,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedWorkshop = newValue;
                      if (selectedFilter == 'Hazır Ürünler') {
                        _fetchCollectionName();
                      } else {
                        _fetchCollectionWait();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(50)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildFilterDropdown(),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery.value = value;
                          });
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ara',
                          hintStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white,
                          prefixIconColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
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
                      .where((work) => work['urun']
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 16, bottom: 16),
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
                                      role == "Dokuma"
                                          ? "Dokunmuş ${data['urun']}"
                                          : role == "Boyama"
                                              ? "Boyanmış ${data['urun']}"
                                              : role == "Kesim"
                                                  ? "Kesilmiş ${data['urun']}"
                                                  : role == "Dikim"
                                                      ? "Dikilmiş ${data['urun']}"
                                                      : role == "Dolum"
                                                          ? "Doldurulmuş ${data['urun']}"
                                                          : role == "Paketleme"
                                                              ? "${data['urun']}"
                                                              : "${data['urun']}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (data['denye'] != null)
                                      Text(
                                        "Denye: ${data['denye']}",
                                        style: const TextStyle(
                                          fontSize: 13,
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
