import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SearchableDropdown({
    Key? key,
    required this.hintText,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late List<String> filteredItems;
  late TextEditingController searchController;
  bool showList = false;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController = TextEditingController();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        showList = false;
        filteredItems = widget.items;
      } else {
        showList = true;
        filteredItems = widget.items
            .where((item) =>
                item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: (value) {
            _filterItems(value);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (showList) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(
              maxHeight: 200, // Liste boyutunu sınırlandır
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: filteredItems.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredItems[index]),
                  onTap: () {
                    setState(() {
                      searchController.text = filteredItems[index];
                      showList = false; // Listeyi kapat
                    });
                    widget.onChanged(filteredItems[index]);
                  },
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
