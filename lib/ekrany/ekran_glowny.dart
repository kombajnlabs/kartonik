import 'dart:math' as matematyka;

import 'package:flutter/material.dart';

import '../modele/fiszka.dart';
import '../modele/zestaw.dart';
import '../widgety/karta_zestawu.dart';
import '../widgety/pusty_stan.dart';
import 'ekran_cwiczenia.dart';
import 'ekran_dodawania_fiszki.dart';
import 'ekran_nowego_zestawu.dart';

class EkranGlowny extends StatefulWidget {
  const EkranGlowny({
    required this.zestawy,
    required this.onDodajZestaw,
    required this.onDodajFiszki,
    required this.onUsunZestaw,
    super.key,
  });

  final List<Zestaw> zestawy;
  final Future<void> Function(Zestaw) onDodajZestaw;
  final Future<void> Function(Zestaw, List<Fiszka>) onDodajFiszki;
  final Future<void> Function(Zestaw) onUsunZestaw;

  @override
  State<EkranGlowny> createState() => _StanEkranuGlownego();
}

class _StanEkranuGlownego extends State<EkranGlowny> {
  Future<void> otworzTworzenieZestawu() async {
    final zestaw = await Navigator.of(context).push<Zestaw>(
      MaterialPageRoute<Zestaw>(builder: (_) => const EkranNowegoZestawu()),
    );
    if (zestaw != null) {
      try {
        await widget.onDodajZestaw(zestaw);
      } on Object catch (blad) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się zapisać zestawu: $blad')),
        );
      }
    }
  }

  void otworzDodawanieFiszki(Zestaw zestaw) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => EkranDodawaniaFiszki(
              zestaw: zestaw,
              onDodajFiszki: (fiszki) => widget.onDodajFiszki(zestaw, fiszki),
            ),
          ),
        )
        .then((_) => setState(() {}));
  }

  void otworzLosowaSesje() {
    final fiszki = widget.zestawy.expand((zestaw) => zestaw.fiszki).toList()
      ..shuffle(matematyka.Random());
    if (fiszki.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EkranCwiczenia(
          zestaw: Zestaw(nazwa: 'Losowa sesja', fiszki: fiszki),
        ),
      ),
    );
  }

  Future<void> usunZestaw(Zestaw zestaw) async {
    final potwierdzenie = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: const Text('Usunąć zestaw?'),
        content: Text(
          'Zestaw „${zestaw.nazwa}” i wszystkie jego fiszki zostaną usunięte bez możliwości przywrócenia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Usuń zestaw'),
          ),
        ],
      ),
    );
    if (potwierdzenie != true) {
      return;
    }

    try {
      await widget.onUsunZestaw(zestaw);
    } on Object catch (blad) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się usunąć zestawu: $blad')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kartonik'),
            Text(
              'Nauka, która zostaje na dłużej',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xff77778b),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: otworzTworzenieZestawu,
            tooltip: 'Utwórz zestaw',
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      body: widget.zestawy.isEmpty
          ? PustyStan(onUtworz: otworzTworzenieZestawu)
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff4f46e5), Color(0xff7c3aed)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x244f46e5),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Czas na naukę',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  '${widget.zestawy.length} ${widget.zestawy.length == 1 ? 'zestaw gotowy' : 'zestawów gotowych'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xffffe08a),
                            size: 52,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              widget.zestawy.any(
                                (zestaw) => zestaw.fiszki.isNotEmpty,
                              )
                              ? otworzLosowaSesje
                              : null,
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text(
                            'Losuj fiszki ze wszystkich zestawów',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Twoje zestawy',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${widget.zestawy.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.zestawy.map(
                  (zestaw) => KartaZestawu(
                    zestaw: zestaw,
                    onDodajFiszke: () => otworzDodawanieFiszki(zestaw),
                    onUsun: () => usunZestaw(zestaw),
                    onCwicz: zestaw.fiszki.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => EkranCwiczenia(zestaw: zestaw),
                            ),
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: otworzTworzenieZestawu,
        icon: const Icon(Icons.add),
        label: const Text('Nowy zestaw'),
      ),
    );
  }
}
