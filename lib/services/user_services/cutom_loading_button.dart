import 'package:flutter/material.dart';

class CustomLoadingButton extends StatelessWidget {
  final bool? isLoading;
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final double borderRadius;

  const CustomLoadingButton({
    Key? key,
    this.isLoading,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.black,
    this.borderRadius = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, right: 16),
      child: ElevatedButton(
        onPressed: (isLoading ?? false) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: (isLoading ?? false)
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
