import 'package:flutter/material.dart';

/// Logo widget for LaundryGO app using the official image logo.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double? fontSize;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 90,
    this.showText = true,
    this.fontSize,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Foto logo sudah mencakup 4 kuadran icon dan teks LOUNDRYGO
    return Image.asset(
      'assets/images/logo.png',
      width: size * 1.35,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/logo.jpg',
          width: size * 1.35,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
