// text_field_with_counter.dart
import 'package:flutter/material.dart';

class TextFieldWithRegister extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  const TextFieldWithRegister({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
  }) : super(key: key);

  @override
  _TextFieldWithRegisterState createState() => _TextFieldWithRegisterState();
}

class _TextFieldWithRegisterState extends State<TextFieldWithRegister> {
  void _updateValue(int delta) {
    int currentValue = int.tryParse(widget.controller.text) ?? 0;
    currentValue = (currentValue + delta).clamp(0, double.infinity).toInt();
     
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
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15),
            child: Container(
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
