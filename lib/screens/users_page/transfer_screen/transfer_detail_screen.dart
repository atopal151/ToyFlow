import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/pdf_services.dart';
import '../../adminPage/admin_work_shop_screen/work_detail_screen/work_module/work_shop_list_item.dart';

class TransferDetailScreen extends StatefulWidget {
  final String title;
  final String collection;

  const TransferDetailScreen({
    Key? key,
    required this.title,
    required this.collection,
  }) : super(key: key);

  @override
  State<TransferDetailScreen> createState() => _TransferDetailScreenState();
}

class _TransferDetailScreenState extends State<TransferDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _generatePdf() async {
    // Firestore'dan ürün verilerini al
    final snapshot = await _firestore
        .collection(widget.collection)
        .where("miktar", isNotEqualTo: 0)
        .get();

    // Veriyi Map olarak bir listeye dönüştür
    final data = snapshot.docs
        .map((doc) => doc.data())
        .toList();

    // PDF dosyasını oluştur ve kaydet
    // ignore: use_build_context_synchronously
    await PdfService.generatePdf(context, widget.title, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: _generatePdf, // PDF oluşturma fonksiyonunu çağırıyoruz
              child: const Icon(Icons.picture_as_pdf),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Ürün Listesi Başlığı
          const Text(
            'Ürün Listesi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Ürünlerin Listelendiği Kısım
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

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    // Her bir ürün belgesini WorkshopListItem içine gönderiyoruz
                    final work = products[index].data() as Map<String, dynamic>;
                    return WorkshopListItem(work: work,atolye: widget.title,);
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
