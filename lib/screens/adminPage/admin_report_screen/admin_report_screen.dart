import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toyflow/screens/adminPage/admin_report_screen/admin_report_services/report_services.dart';
import 'package:toyflow/services/user_component/dropdown_selector.dart';

import '../../../services/user_component/cutom_loading_button.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportServices _reportServices = ReportServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedWorkshop;
  String? selectedCollection;
  String? selectedNitelik;
  String? selectedTransaction;
  String? selectedToy;
  String? selectedColor;
  String? selectedBoyut;
  String? selectedAksesuar;
  String? selectedFine;
  String? selectedGramaj;
  String? selectedDenye;

  bool isLoading = false;

  List<String> workshopNames = [];
  List<String> toyNames = [];
  List<String> colorNames = [];
  List<String> boyutNames = [];
  List<String> aksesuarNames = [];
  List<String> fineNames = [];
  List<String> gramajNames = [];
  List<String> denyeNames = [];

  List<String> transactionTypes = [
    "Stok Ekleme",
    "Stok Düşümü",
    "Fire Kaydı",
    "Stok Satış"
  ];

  Map<String, Map<String, String>> workshopMap = {};

  List<Map<String, dynamic>> reportData = [];
  @override
  void initState() {
    super.initState();
    _fetchWorkshops();
    _fetchToyName();
    _fetchToyColors();
    _fetchToyBoyut();
    _fetchToyAksesuar();
    _fetchFine();
    _fetchGramaj();
    _fetchDenye();
  }

  Future<void> _fetchFilteredReports() async {
    setState(() {
      isLoading = true;
      reportData.clear();
    });

    try {
      Query query = _firestore.collection("movers");

      // **Atölye filtresi**
      if (selectedCollection != null) {
        String formattedAtolye =
            selectedCollection!.toLowerCase().replaceAll(" ", "_");
        query = query.where("atelye", isEqualTo: formattedAtolye);
        print("Firestore için gönderilen atölye: $formattedAtolye");
      }

      // **Filtreleri yalnızca dolu olanlar için uygula**
      if (selectedTransaction != null && selectedTransaction!.isNotEmpty) {
        query = query.where("islemTuru", isEqualTo: selectedTransaction);
      }

      if (selectedToy != null && selectedToy!.isNotEmpty) {
        query = query.where("malzeme", isEqualTo: selectedToy);
      }

      if (selectedColor != null && selectedColor!.isNotEmpty) {
        query = query.where("renk", isEqualTo: selectedColor);
      }

      if (selectedBoyut != null && selectedBoyut!.isNotEmpty) {
        query = query.where("boyut", isEqualTo: selectedBoyut);
      }

      if (selectedAksesuar != null && selectedAksesuar!.isNotEmpty) {
        query = query.where("aksesuar", isEqualTo: selectedAksesuar);
      }

      if (selectedFine != null && selectedFine!.isNotEmpty) {
        query = query.where("fine", isEqualTo: selectedFine);
      }

      if (selectedGramaj != null && selectedGramaj!.isNotEmpty) {
        query = query.where("gramaj", isEqualTo: selectedGramaj);
      }

      if (selectedDenye != null && selectedDenye!.isNotEmpty) {
        query = query.where("denye", isEqualTo: selectedDenye);
      }

      // **Firestore'dan Veriyi Çekme**
      QuerySnapshot querySnapshot = await query.get();

      setState(() {
        reportData = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });

      print("Firestore'dan gelen veri sayısı: ${reportData.length}");
    } catch (e) {
      print("Hata: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchWorkshops() async {
    List<Map<String, String>> workshops = await ReportServices().getWorkshops();

    setState(() {
      workshopNames = workshops.map((w) => w["name"]!).toList();
      workshopMap = {
        for (var w in workshops)
          w["name"]!: {
            "collection": w["collection"]!,
            "nitelik": w["nitelik"]!, // Nitelik alanını da saklıyoruz
          }
      };
    });
  }

  Future<void> _fetchToyName() async {
    String collectionToFetch = "toy_name"; // Varsayılan koleksiyon
    String docName = "name"; // Varsayılan name

    switch (selectedNitelik) {
      case "Dokuma":
        if (selectedTransaction == "Stok Ekleme") {
          collectionToFetch = "kumas";
          docName = "kumas";
        } else if (selectedTransaction == "Stok Düşümü") {
          collectionToFetch = "iplik";
          docName = "iplik";
        } else if (selectedTransaction == "Fire Kaydı") {
          collectionToFetch = "iplik";
          docName = "iplik";
        }
        break;

      case "Boyama":
        if (selectedTransaction == "Stok Ekleme") {
          collectionToFetch = "kumas";
          docName = "kumas";
        } else if (selectedTransaction == "Stok Düşümü") {
          collectionToFetch = "kumas";
          docName = "kumas";
        } else if (selectedTransaction == "Fire Kaydı") {
          collectionToFetch = "kumas";
          docName = "kumas";
        }
        break;

      case "Kesim":
        if (selectedTransaction == "Stok Ekleme") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Stok Düşümü") {
          collectionToFetch = "kumas";
          docName = "kumas";
        } else if (selectedTransaction == "Fire Kaydı") {
          collectionToFetch = "kumas";
          docName = "kumas";
        }
        break;

      case "Dikim":
        if (selectedTransaction == "Stok Ekleme") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Stok Düşümü") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Fire Kaydı") {
          collectionToFetch = "toy_name";
          docName = "name";
        }
        break;

      case "Dolum":
        if (selectedTransaction == "Stok Ekleme") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Stok Düşümü") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Fire Kaydı") {
          collectionToFetch = "toy_name";
          docName = "name";
        }
        break;

      case "Paketleme":
        if (selectedTransaction == "Stok Ekleme") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Stok Düşümü") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Fire Kaydı") {
          collectionToFetch = "toy_name";
          docName = "name";
        }
        break;

      case "Transfer":
        if (selectedTransaction == "Stok Ekleme") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Stok Düşümü") {
          collectionToFetch = "toy_name";
          docName = "name";
        } else if (selectedTransaction == "Fire Kaydı") {
          collectionToFetch = "toy_name";
          docName = "name";
        }
        break;

      default:
        collectionToFetch = "toy_name";
        docName = "name";
    }

    List<String> fetchedToyNames =
        await _reportServices.getToyNames(collectionToFetch, docName);

    setState(() {
      toyNames = fetchedToyNames;
    });
  }

  Future<void> _fetchToyColors() async {
    List<String> fetchedColors = await _reportServices.getToyColors();

    setState(() {
      colorNames = fetchedColors;
    });
  }

  Future<void> _fetchToyBoyut() async {
    List<String> fetchedBoyut = await _reportServices.getToyBoyut();

    setState(() {
      boyutNames = fetchedBoyut;
    });
  }

  Future<void> _fetchToyAksesuar() async {
    List<String> fetchedAksesuar = await _reportServices.getToyAksesuar();

    setState(() {
      aksesuarNames = fetchedAksesuar;
    });
  }

  Future<void> _fetchFine() async {
    List<String> fetchedFine = await _reportServices.getFine();

    setState(() {
      fineNames = fetchedFine;
    });
  }

  Future<void> _fetchGramaj() async {
    List<String> fetchedGramaj = await _reportServices.getGramaj();

    setState(() {
      gramajNames = fetchedGramaj;
    });
  }

  Future<void> _fetchDenye() async {
    List<String> fetchedDenye = await _reportServices.getDenye();

    setState(() {
      denyeNames = fetchedDenye;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Raporlar"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //----------Atolye Seçimi--------
            workshopNames.isEmpty
                ? Center(child: CircularProgressIndicator())
                : DropdownSelector(
                    hintText: "Atölye Seçiniz",
                    items: workshopNames,
                    selectedValue: selectedWorkshop,
                    onChanged: (value) => {
                          setState(() {
                            selectedWorkshop = value;
                            selectedCollection =
                                workshopMap[value!]?["collection"];
                            selectedNitelik = workshopMap[value]
                                ?["nitelik"]; // Nitelik bilgisi güncellendi
                            toyNames.clear();
                            print(selectedCollection);
                            
                          }),
                          _fetchToyName()
                        },
                    icon: Icons.factory),

            //------------İşlem Türü Seçimi------
            DropdownSelector(
                hintText: "İşlem Türünü Seçiniz",
                items: transactionTypes,
                selectedValue: selectedTransaction,
                onChanged: (value) => {
                      setState(() {
                        selectedTransaction = value;
                      })
                    },
                icon: Icons.list),

            //--------urun seçimi---------
            toyNames.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : DropdownSelector(
                    hintText: "Ürün",
                    items: toyNames,
                    selectedValue: selectedToy,
                    onChanged: (value) => {
                      setState(() {
                        selectedToy = value;
                      })
                    },
                    icon: Icons.toys),

            //--------Renk Seçimi---------

            Visibility(
              visible: (selectedTransaction == "Stok Ekleme" &&
                      (selectedNitelik == "Boyama" ||
                          selectedNitelik == "Kesim" ||
                          selectedNitelik == "Dikim" ||
                          selectedNitelik == "Dolum" ||
                          selectedNitelik == "Paketleme" ||
                          selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Stok Düşümü" &&
                      (selectedNitelik == "Kesim" ||
                          selectedNitelik == "Dikim" ||
                          selectedNitelik == "Dolum" ||
                          selectedNitelik == "Paketleme" ||
                          selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Fire Kaydı" &&
                      (selectedNitelik == "Kesim" ||
                          selectedNitelik == "Dikim" ||
                          selectedNitelik == "Dolum" ||
                          selectedNitelik == "Paketleme" ||
                          selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Stok Satış" &&
                      (selectedNitelik == "Transfer")),
              child: colorNames.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownSelector(
                      hintText: "Renk Seçiniz",
                      items: colorNames,
                      selectedValue: selectedColor,
                      onChanged: (value) {
                        setState(() {
                          selectedColor = value;
                        });
                      },
                      icon: Icons.color_lens),
            ),

            //--------Boyut Seçimi---------
            Visibility(
              visible: (selectedTransaction == "Stok Ekleme" &&
                      (selectedNitelik == "Kesim" ||
                          selectedNitelik == "Dikim" ||
                          selectedNitelik == "Dolum" ||
                          selectedNitelik == "Paketleme" ||
                          selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Stok Düşümü" &&
                      (selectedNitelik == "Dikim" ||
                          selectedNitelik == "Dolum" ||
                          selectedNitelik == "Paketleme" ||
                          selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Fire Kaydı" &&
                      (selectedNitelik == "Dikim" ||
                          selectedNitelik == "Dolum" ||
                          selectedNitelik == "Paketleme" ||
                          selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Stok Satış" &&
                      (selectedNitelik == "Transfer")),
              child: boyutNames.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownSelector(
                      hintText: "Boyut Seçiniz",
                      items: boyutNames,
                      selectedValue: selectedBoyut,
                      onChanged: (value) {
                        setState(() {
                          selectedBoyut = value;
                        });
                      },
                      icon: Icons.height),
            ),

            //--------Aksesuar Seçimi---------
            Visibility(
              visible: (selectedTransaction == "Stok Ekleme" &&
                      (selectedNitelik == "Paketleme" ||
                          selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Stok Düşümü" &&
                      (selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Fire Kaydı" &&
                      (selectedNitelik == "Transfer")) ||
                  (selectedTransaction == "Stok Satış" &&
                      (selectedNitelik == "Transfer")),
              child: aksesuarNames.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownSelector(
                      hintText: "Aksesuar Seçiniz",
                      items: aksesuarNames,
                      selectedValue: selectedAksesuar,
                      onChanged: (value) {
                        setState(() {
                          selectedAksesuar = value;
                        });
                      },
                      icon: Icons.style),
            ),

            //--------Fine Seçimi---------
            Visibility(
              visible: (selectedTransaction == "Stok Ekleme" &&
                      (selectedNitelik == "Dokuma" ||
                          selectedNitelik == "Boyama")) ||
                  (selectedTransaction == "Stok Düşümü" &&
                      (selectedNitelik == "Boyama" ||
                          selectedNitelik == "Kesim")) ||
                  (selectedTransaction == "Fire Kaydı" &&
                      (selectedNitelik == "Boyama" ||
                          selectedNitelik == "Kesim")),
              child: fineNames.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownSelector(
                      hintText: "Fine Seçiniz",
                      items: fineNames,
                      selectedValue: selectedFine,
                      onChanged: (value) {
                        setState(() {
                          selectedFine = value;
                        });
                      },
                      icon: Icons.layers),
            ),

            //--------Gramaj Seçimi---------
            Visibility(
              visible: (selectedTransaction == "Stok Ekleme" &&
                      (selectedNitelik == "Dokuma" ||
                          selectedNitelik == "Boyama")) ||
                  (selectedTransaction == "Stok Düşümü" &&
                      (selectedNitelik == "Boyama" ||
                          selectedNitelik == "Kesim")) ||
                  (selectedTransaction == "Fire Kaydı" &&
                      (selectedNitelik == "Boyama" ||
                          selectedNitelik == "Kesim")),
              child: gramajNames.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownSelector(
                      hintText: "Gramaj Seçiniz",
                      items: gramajNames,
                      selectedValue: selectedGramaj,
                      onChanged: (value) {
                        setState(() {
                          selectedGramaj = value;
                        });
                      },
                      icon: Icons.compress),
            ),

            //--------denye Seçimi---------
            Visibility(
              visible: (selectedTransaction == "Stok Düşümü" &&
                      (selectedNitelik == "Dokuma")) ||
                  (selectedTransaction == "Fire Kaydı" &&
                      (selectedNitelik == "Dokuma")),
              child: denyeNames.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownSelector(
                      hintText: "Denye Seçiniz",
                      items: denyeNames,
                      selectedValue: selectedDenye,
                      onChanged: (value) {
                        setState(() {
                          selectedDenye = value;
                        });
                      },
                      icon: Icons.format_line_spacing),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: CustomLoadingButton(
                      onPressed: () {
                        _fetchFilteredReports();
                        print(selectedNitelik);
                        print(selectedTransaction);
                        print(selectedCollection);
                      },
                      text: 'Sorgula',
                    ),
                  ),
                ),
                Expanded(
                  flex:1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: CustomLoadingButton(
                      onPressed: () {
                        //pdf e aktarma işlemleri
                      },
                      text: 'PDF`e aktar',
                    ),
                  ),
                ),
              ],
            ),

            // **Listeleme Bölümü**
            isLoading
                ? Center(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ))
                : reportData.isEmpty
                    ? Center(child: Text("Sonuç bulunamadı"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: reportData.length,
                        itemBuilder: (context, index) {
                          // ignore: no_leading_underscores_for_local_identifiers
                          String _formatTimestamp(Timestamp? timestamp) {
                            if (timestamp == null) {
                              return "Bilinmiyor"; // Eğer timestamp null ise
                            }
                            DateTime date = timestamp
                                .toDate(); // Firestore Timestamp -> DateTime
                            return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}"; // Özel format
                          }

                          var report = reportData[index];
                          return Card(
                            color: Colors.white,
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(
                                  "Malzeme: ${report["malzeme"] ?? "Bilinmiyor"}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "İşlem Türü: ${report["islemTuru"] ?? "Bilinmiyor"}"),
                                  Text(
                                      "Atelye: ${report["atelye"] ?? "Bilinmiyor"}"),
                                  Text(
                                      "Miktar: ${report["miktar"] ?? "Bilinmiyor"}"),
                                  Text(
                                      "Renk: ${report["renk"] ?? "Bilinmiyor"}"),
                                  Text(
                                      "Aksesuar: ${report["aksesuar"] ?? "Yok"}"),
                                  Text(
                                      "Açıklama: ${report["aciklama"] ?? "Bilinmiyor"}"),
                                  Text(
                                    "Tarih: ${_formatTimestamp(report["tarih"])}",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
