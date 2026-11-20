import 'package:flutter/material.dart';

import '../modele/fiszka.dart';

class KartaDoCwiczenia extends StatelessWidget {
  const KartaDoCwiczenia({
    required this.fiszka,
    required this.pokazTyl,
    required this.kat,
    super.key,
  });

  final Fiszka fiszka;
  final bool pokazTyl;
  final double kat;

  @override
  Widget build(BuildContext context) {
    final bool stronaTylna = kat > 1.5708;
    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      shadowColor: const Color(0x334f46e5),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(kat),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: pokazTyl
                  ? const [Color(0xffeef2ff), Color(0xffc7d2fe)]
                  : const [Color(0xff4f46e5), Color(0xff7c3aed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(stronaTylna ? 3.14159 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stronaTylna ? 'ODPOWIEDŹ' : 'PYTANIE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: stronaTylna ? Colors.black54 : Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  stronaTylna ? fiszka.tyl : fiszka.przod,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: stronaTylna ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
