import 'package:flutter/material.dart';

import '../../../services/user_services/dropdown_selector.dart';

class ToyDetailScreen extends StatefulWidget {
  final String urun;
  final String? renk;
  final String? boyut;
  final String? aksesuar;
  final String? atolye;

  const ToyDetailScreen({
    super.key,
    required this.urun,
    this.renk,
    this.boyut,
    this.aksesuar,
    this.atolye,
  });

  @override
  State<ToyDetailScreen> createState() => _ToyDetailScreenState();
}

class _ToyDetailScreenState extends State<ToyDetailScreen> {
  String title = "";

  String? _selectedBoyut; // Seçilen  boyut
  String? _selectedRenk; // Seçilen  renk
  String? _selectedMalzeme; // Seçilen ürün
  String? _selectedAksesuar; // Seçilen aksesuar
  @override
  void initState() {
    super.initState();
    title = widget.urun;
    _selectedMalzeme == widget.urun;
    _selectedRenk == widget.renk;
    _selectedAksesuar == widget.aksesuar;
    _selectedBoyut == widget.boyut;
  }

  final List<String> _urun = [
    'Çilek Tavşan',
    'Havuç Tavşan',
    'Kapşonlu Panda',
    'Su Samuru',
    'Bambu Panda',
    'Peluş Ayı'
  ]; // Ürün listesi

  final List<String> _boyut = [
    '30',
    '40',
    '50',
    '60',
    '70',
    '80',
    '90',
    '100'
  ]; // Ürün listesi

  final List<String> _renk = [
    'Kırmızı',
    'Siyah',
    'Beyaz',
    'Turuncu',
    'Pembe',
    'Gri'
  ];
  final List<String> _aksesuar = [
    'Yok',
    'Papyon',
    'Kurdela',
    'Bıyık',
    'Kuyruk',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Ürün adı başlık olarak gösteriliyor
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/fullmov.webp',
                  width: 250,
                  height: 320,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  if (widget.atolye == "Denizli Depo" ||
                      widget.atolye == "Almanya Depo" ||
                      widget.atolye == "İstanbul Depo" ||
                      widget.atolye == "Dokuma Atölyesi" ||
                      widget.atolye == "Boyama Atölyesi" ||
                      widget.atolye == "Kesim Atölyesi" ||
                      widget.atolye == "Dikim Atölyesi" ||
                      widget.atolye == "Dolum Atölyesi" ||
                      widget.atolye == "Paketleme Atölyesi")
                    DropdownSelector(
                      hintText: 'Ürün',
                      items: _urun,
                      selectedValue: _selectedMalzeme,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMalzeme = newValue;
                          title = _selectedMalzeme!;
                        });
                      },
                      icon: Icons.arrow_drop_down,
                    ),
                  if (widget.atolye == "Denizli Depo" ||
                      widget.atolye == "Almanya Depo" ||
                      widget.atolye == "İstanbul Depo" ||
                      widget.atolye == "Boyama Atölyesi" ||
                      widget.atolye == "Kesim Atölyesi" ||
                      widget.atolye == "Dikim Atölyesi" ||
                      widget.atolye == "Dolum Atölyesi" ||
                      widget.atolye == "Paketleme Atölyesi")
                    // Renk seçme dropdown

                    DropdownSelector(
                      hintText: 'Renk',
                      items: _renk,
                      selectedValue: _selectedRenk,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRenk = newValue;
                        });
                      },
                      icon: Icons.arrow_drop_down,
                    ),
                  if (widget.atolye == "Denizli Depo" ||
                      widget.atolye == "Almanya Depo" ||
                      widget.atolye == "İstanbul Depo" ||
                      widget.atolye == "Kesim Atölyesi" ||
                      widget.atolye == "Dikim Atölyesi" ||
                      widget.atolye == "Dolum Atölyesi" ||
                      widget.atolye == "Paketleme Atölyesi")
                    // boyut seçme dropdown
                    DropdownSelector(
                      hintText: 'Boyut',
                      items: _boyut,
                      selectedValue: _selectedBoyut,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBoyut = newValue;
                        });
                      },
                      icon: Icons.arrow_drop_down,
                    ),
                  if (widget.atolye == "Denizli Depo" ||
                      widget.atolye == "Almanya Depo" ||
                      widget.atolye == "İstanbul Depo" ||
                      widget.atolye == "Kesim Atölyesi" ||
                      widget.atolye == "Dikim Atölyesi" ||
                      widget.atolye == "Dolum Atölyesi" ||
                      widget.atolye == "Paketleme Atölyesi")
                    //aksesuar
                    DropdownSelector(
                      hintText: 'Aksesuar',
                      items: _aksesuar,
                      selectedValue: _selectedAksesuar,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAksesuar = newValue;
                        });
                      },
                      icon: Icons.arrow_drop_down,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 49, 51, 52),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            'Getir',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text("depo1"),
                  const Text("depo1"),
                  const Text("depo1")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
