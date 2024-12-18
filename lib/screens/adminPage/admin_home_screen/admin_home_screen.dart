import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toyflow/screens/adminPage/admin_setting_screen/admin_setting_screen.dart';
import 'package:toyflow/screens/adminPage/mover_screen/mover_screen.dart';
import 'package:toyflow/screens/users/transfer_screen/transfer_detail_screen.dart';
import 'package:toyflow/services/user_services/get_data_table.dart';
import '../../../services/user_services/product_services.dart';
import '../admin_work_shop_screen/work_detail_screen/work_detail_screen.dart';
import 'adminhome_services/admin_home_services.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ProductServices productServices = Get.find();
  final AdminHomeService adminHomeService = AdminHomeService();
  final DataTableService _dataTableService = DataTableService();

  List<Map<String, dynamic>> _atolyeList = [];
  List<int> _atolyeDailyCounts = [];
  List<String> _depoName = [];
  List<String> _depoCollection = [];
  bool _isAtolyeLoaded = false;
  bool _isDepoLoaded = false;

  @override
  void initState() {
    super.initState();
    print(_isDepoLoaded);
    print(_isAtolyeLoaded);
    if (!_isAtolyeLoaded) {
      _fetchAtolyeList();
    }
    if (!_isDepoLoaded) {
      _fetchDepoTitleList();
      _fetchDepoCollectionList();
    }
  }

  Future<void> _fetchAtolyeList() async {
    if (_isAtolyeLoaded) return;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('atolyeler')
          .orderBy("nitelik")
          .get();
      List<Map<String, dynamic>> fetchedAtolyeler =
          querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'nitelik': doc['nitelik'],
          'collection': doc['collection'],
        };
      }).toList();

      List<int> fetchedDailyCounts = [];
      for (var atolye in fetchedAtolyeler) {
        int dailyCount =
            await adminHomeService.fetchDailyStockOperations(atolye['nitelik']);
        fetchedDailyCounts.add(dailyCount);
      }

      setState(() {
        _atolyeList = fetchedAtolyeler;
        _atolyeDailyCounts = fetchedDailyCounts;
        _isAtolyeLoaded = true;
      });
    } catch (e) {
      print("Atölyeler alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchDepoTitleList() async {
    if (_isDepoLoaded) return;
    try {
      List<String> fetchedDepoTitles =
          await _dataTableService.getCollectionData('depolar', 'title');
      setState(() {
        _depoName = fetchedDepoTitles;
      });
      print("Depo Başlıkları: $_depoName");
    } catch (e) {
      print("Depo başlıkları alınırken hata oluştu: $e");
    }
  }

  Future<void> _fetchDepoCollectionList() async {
    if (_isDepoLoaded) return;
    try {
      List<String> fetchedDepoCollections =
          await _dataTableService.getCollectionData('depolar', 'collection');
      setState(() {
        _depoCollection = fetchedDepoCollections;
      });
      print("Depo Koleksiyonları: $_depoCollection");

      if (_depoName.isNotEmpty && _depoCollection.isNotEmpty) {
        setState(() {
          _isDepoLoaded = true;
        });
      }
    } catch (e) {
      print("Depo koleksiyonları alınırken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Get.to(() => const AdminSettingScreen());
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 23,
                  backgroundImage: AssetImage('images/erkek.webp'),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${productServices.firstName.value} ${productServices.lastName.value}",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const Text(
                  "Yönetici",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('movers')
                .where('okundu', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onTap: () {
                        Get.to(() => const MoverScreen());
                      },
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Depolar",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _depoName.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildDepoRow(
                        _depoName[index],
                        "------",
                        _depoCollection[index],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Atölyeler",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _atolyeList.length,
                itemBuilder: (context, index) {
                  final atolye = _atolyeList[index];
                  final dailyCount = _atolyeDailyCounts[index];
                  return _buildAtolyeRow(
                    atolye['name'],
                    dailyCount,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtolyeRow(String name, int dailyCount) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              print("11111 $name");
              Get.to(() => WorkDetailScreen(selectedWorkshop: name));
            },
            child: Container(
              padding: const EdgeInsets.all(15.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 2, 2, 2),
                    Color.fromARGB(255, 75, 75, 75),
                    Color.fromARGB(255, 205, 199, 199),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: DecorationImage(
                  image: const AssetImage("images/backgorund.webp"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2),
                    BlendMode.dstATop,
                  ),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.transfer_within_a_station, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          "+$dailyCount İşlem",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepoRow(String roomName, String temperature, String collection) {
  return InkWell(
    onTap: () => Get.to(
      TransferDetailScreen(title: roomName, collection: collection),
    ),
    child: Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('images/depo.webp'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black54,  
            BlendMode.darken, 
          ),
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.7),  
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.refresh, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Koleksiyon: $collection',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
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
}}