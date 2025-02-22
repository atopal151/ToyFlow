import 'package:flutter/material.dart';

class CustomLoadingButton extends StatelessWidget {
  final bool? isLoading;
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final double borderRadius;

  const CustomLoadingButton({
    super.key,
    this.isLoading = false,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.black,
    this.borderRadius = 50,
  });

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
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Yükleniyor...",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
