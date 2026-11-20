import 'package:flutter/material.dart';

class PrzyciskOceny extends StatelessWidget {
  const PrzyciskOceny({
    required this.tekst,
    required this.ikona,
    required this.kolor,
    required this.onPressed,
    super.key,
  });

  final String tekst;
  final IconData ikona;
  final Color kolor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(ikona),
        label: Text(tekst),
        style: FilledButton.styleFrom(
          backgroundColor: kolor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 17),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
