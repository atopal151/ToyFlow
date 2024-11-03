// text_field_with_counter.dart
import 'package:flutter/material.dart';

class TextFieldWithCounter extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  const TextFieldWithCounter({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
  }) : super(key: key);

  @override
  _TextFieldWithCounterState createState() => _TextFieldWithCounterState();
}

class _TextFieldWithCounterState extends State<TextFieldWithCounter> {
  void _updateValue(int delta) {
    int currentValue = int.tryParse(widget.controller.text) ?? 0;
    currentValue = (currentValue + delta).clamp(0, double.infinity).toInt();
    
    // Güncelleme işlemini microtask içinde yaparak hasSize hatasını önlüyoruz
    Future.microtask(() {
      setState(() {
        widget.controller.text = currentValue.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Arka plan rengi beyaz
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4), // Gölgenin pozisyonu
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.grey[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => _updateValue(-1),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _updateValue(1),
        ),
      ],
    );
  }
}
