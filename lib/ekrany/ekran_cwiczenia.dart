import 'package:flutter/material.dart';

import '../modele/fiszka.dart';
import '../modele/zestaw.dart';
import '../widgety/karta_do_cwiczenia.dart';
import '../widgety/przycisk_oceny.dart';

class EkranCwiczenia extends StatefulWidget {
  const EkranCwiczenia({required this.zestaw, super.key});

  final Zestaw zestaw;

  @override
  State<EkranCwiczenia> createState() => _StanCwiczenia();
}

class _StanCwiczenia extends State<EkranCwiczenia>
    with SingleTickerProviderStateMixin {
  late final AnimationController kontrolerObrotu;
  int indeks = 0;
  int punkty = 0;
  int liczbaOcenionych = 0;
  bool pokazTyl = false;
  double przesuniecie = 0;

  Fiszka get aktualna => widget.zestaw.fiszki[indeks];

  @override
  void initState() {
    super.initState();
    kontrolerObrotu = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    kontrolerObrotu.dispose();
    super.dispose();
  }

  void obroc() {
    setState(() => pokazTyl = !pokazTyl);
    if (pokazTyl) {
      kontrolerObrotu.forward();
    } else {
      kontrolerObrotu.reverse();
    }
  }

  void przejdzDo(int nowyIndeks) {
    if (nowyIndeks < 0 || nowyIndeks >= widget.zestaw.fiszki.length) {
      return;
    }
    setState(() {
      indeks = nowyIndeks;
      pokazTyl = false;
      przesuniecie = 0;
    });
    kontrolerObrotu.reset();
  }

  void obsluzPrzesuniecie(DragEndDetails szczegoly) {
    if (szczegoly.primaryVelocity == null || szczegoly.primaryVelocity == 0) {
      return;
    }
    if (szczegoly.primaryVelocity! < 0) {
      przejdzDo(indeks + 1);
    } else {
      przejdzDo(indeks - 1);
    }
  }

  Future<void> ocenFiszke(bool dobrze) async {
    setState(() {
      liczbaOcenionych++;
      if (dobrze) {
        punkty++;
      }
    });

    if (indeks == widget.zestaw.fiszki.length - 1) {
      await pokazPodsumowanie();
      return;
    }
    przejdzDo(indeks + 1);
  }

  Future<void> pokazPodsumowanie() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          punkty == widget.zestaw.fiszki.length
              ? Icons.emoji_events
              : Icons.flag_rounded,
          color: const Color(0xff6750a4),
          size: 42,
        ),
        title: const Text('Sesja zakończona'),
        content: Text(
          'Twój wynik: $punkty/${widget.zestaw.fiszki.length} punktów',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Gotowe'),
          ),
        ],
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final liczbaFiszek = widget.zestaw.fiszki.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zestaw.nazwa),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.star, size: 17),
                label: Text('$punkty pkt'),
                backgroundColor: const Color(0xffffe8a3),
                side: BorderSide.none,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (indeks + 1) / liczbaFiszek),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sesja ćwiczeniowa',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${indeks + 1} z $liczbaFiszek',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: obroc,
                onHorizontalDragUpdate: (szczegoly) =>
                    setState(() => przesuniecie += szczegoly.primaryDelta ?? 0),
                onHorizontalDragEnd: obsluzPrzesuniecie,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: Matrix4.translationValues(przesuniecie, 0, 0),
                  padding: const EdgeInsets.all(24),
                  child: AnimatedBuilder(
                    animation: kontrolerObrotu,
                    builder: (_, _) => KartaDoCwiczenia(
                      fiszka: aktualna,
                      pokazTyl: pokazTyl,
                      kat: kontrolerObrotu.value * 3.14159,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Text(
                    'Jak poszło?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PrzyciskOceny(
                        tekst: 'Źle',
                        ikona: Icons.close_rounded,
                        kolor: const Color(0xffd64550),
                        onPressed: () => ocenFiszke(false),
                      ),
                      const SizedBox(width: 14),
                      PrzyciskOceny(
                        tekst: 'Dobrze',
                        ikona: Icons.check_rounded,
                        kolor: const Color(0xff2e9d67),
                        onPressed: () => ocenFiszke(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
