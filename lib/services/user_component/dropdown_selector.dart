import 'package:flutter/material.dart';

class DropdownSelector extends StatefulWidget {
  final String hintText;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final IconData icon;

  const DropdownSelector({
    Key? key,
    required this.hintText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.icon,
  }) : super(key: key);

  @override
  _DropdownSelectorState createState() => _DropdownSelectorState();
}

class _DropdownSelectorState extends State<DropdownSelector> {
  late List<String> filteredItems;
  late TextEditingController searchController;
  bool showList = false;
late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController = TextEditingController();

  scrollController = ScrollController(); // ScrollController başlat
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        showList = false;
        filteredItems = widget.items;
      } else {
        showList = true;
        filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleList() {
    setState(() {
      showList = !showList;
      if (showList) {
        filteredItems =
            widget.items; // Listeyi sıfırlar ve tüm öğeleri gösterir
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
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
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 25,
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: _toggleList,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showList) ...[
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  maxHeight: 300, // Max height for the list container
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController, // ScrollController eklendi
                  child: ListView.builder(
                    controller: scrollController, // ScrollController eklendi
                    itemCount: filteredItems.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index >= 10) return null; // İlk 10 öğeyi göster
                      return ListTile(
                        title: Text(filteredItems[index]),
                        onTap: () {
                          setState(() {
                            searchController.text = filteredItems[index];
                            showList = false;
                          });
                          widget.onChanged(filteredItems[index]);
                        },
                      );
                    },
                  ),
                )),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
