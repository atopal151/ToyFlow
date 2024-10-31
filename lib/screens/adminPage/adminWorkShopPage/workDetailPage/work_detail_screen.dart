import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'work_module/dropdown_work_selector.dart';
import 'work_module/work_data_service.dart';
import 'work_module/work_shop_list_item.dart'; // Liste öğesi için ayrı dosya

class WorkDetailScreen extends StatefulWidget {
  final String selectedWorkshop;

  const WorkDetailScreen({Key? key, required this.selectedWorkshop})
      : super(key: key);

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  String? _selectedWorkshop;
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _selectedWorkshop = widget.selectedWorkshop;
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
          Expanded(
            flex: 1,
            child: DropdownWorkSelector(
              hintText: 'Atölye Seç',
              items: WorkshopDataService.workshops,
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
                prefixIcon: const Icon(Icons.search),
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
                stream: WorkshopDataService.getWorkshopData(_selectedWorkshop),
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

                  // Obx sadece burada, liste verilerini filtrelemek için kullanılıyor.
                  return Obx(() {
                    final filteredData = snapshot.data!
                        .where((work) => work['kumas']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.value.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        return WorkshopListItem(work: filteredData[index]);
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
