import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/user_services/pdf_services.dart';
import '../../adminPage/admin_work_shop_screen/work_detail_screen/work_module/work_shop_list_item.dart';

class TransferDetailScreen extends StatefulWidget {
  final String title;
  final String collection;

  const TransferDetailScreen({
    super.key,
    required this.title,
    required this.collection,
  });

  @override
  State<TransferDetailScreen> createState() => _TransferDetailScreenState();
}

class _TransferDetailScreenState extends State<TransferDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _generatePdf() async {
    final snapshot = await _firestore
        .collection(widget.collection)
        .where("miktar", isNotEqualTo: 0)
        .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();

    // ignore: use_build_context_synchronously
    await PdfService.generatePdf(context, widget.title, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: _generatePdf,
              child: const Icon(Icons.picture_as_pdf),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Arama Kutusu
          Padding(
            padding: const EdgeInsets.only(left:16,right: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          // Ürün Listesi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(widget.collection)
                  .where("miktar", isNotEqualTo: 0)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Bu depoda ürün bulunmamaktadır."),
                  );
                }

                // Ürünleri filtreleme
                final products = snapshot.data!.docs
                    .where((doc) {
                      final work = doc.data() as Map<String, dynamic>;
                      final urunName =
                          work['urun']?.toString().toLowerCase() ?? '';
                      return urunName.contains(_searchQuery);
                    })
                    .toList();

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final work = products[index].data() as Map<String, dynamic>;
                    return WorkshopListItem(
                      work: work,
                      atolye: widget.title,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
