import 'package:flutter/material.dart';

import '../modele/fiszka.dart';
import '../modele/zestaw.dart';
import '../widgety/formularz_fiszki.dart';

class EkranDodawaniaFiszki extends StatefulWidget {
  const EkranDodawaniaFiszki({
    required this.zestaw,
    required this.onDodajFiszki,
    super.key,
  });

  final Zestaw zestaw;
  final Future<void> Function(List<Fiszka>) onDodajFiszki;

  @override
  State<EkranDodawaniaFiszki> createState() => _StanDodawaniaFiszki();
}

class _StanDodawaniaFiszki extends State<EkranDodawaniaFiszki> {
  final GlobalKey<FormState> kluczFormularza = GlobalKey<FormState>();
  final List<KontroleryFiszki> kontrolery = <KontroleryFiszki>[
    KontroleryFiszki(),
  ];
  bool zapisywanie = false;

  @override
  void dispose() {
    for (final formularz in kontrolery) {
      formularz.dispose();
    }
    super.dispose();
  }

  void dodajPoleFiszki() {
    setState(() => kontrolery.insert(0, KontroleryFiszki()));
  }

  void usunPole(KontroleryFiszki formularz) {
    if (kontrolery.length == 1) {
      return;
    }
    setState(() {
      formularz.dispose();
      kontrolery.remove(formularz);
    });
  }

  Future<void> zapisz() async {
    if (!(kluczFormularza.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => zapisywanie = true);
    final fiszki = kontrolery
        .map(
          (formularz) => Fiszka(
            przod: formularz.przod.text.trim(),
            tyl: formularz.tyl.text.trim(),
          ),
        )
        .toList();

    try {
      await widget.onDodajFiszki(fiszki);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (blad) {
      if (!mounted) {
        return;
      }
      setState(() => zapisywanie = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać fiszek: $blad')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj fiszki • ${widget.zestaw.nazwa}')),
      body: Form(
        key: kluczFormularza,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff4f46e5), Color(0xff7c3aed)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.library_add_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Dodaj kilka fiszek naraz i ucz się szybciej.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nowe fiszki',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${kontrolery.length}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...kontrolery.asMap().entries.map(
              (wpis) => FormularzFiszki(
                key: ObjectKey(wpis.value),
                numer: wpis.key + 1,
                kontrolery: wpis.value,
                moznaUsunac: kontrolery.length > 1,
                onUsun: () => usunPole(wpis.value),
              ),
            ),
            OutlinedButton.icon(
              onPressed: dodajPoleFiszki,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj kolejną fiszkę'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: zapisywanie ? null : zapisz,
                icon: zapisywanie
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  zapisywanie
                      ? 'Zapisywanie...'
                      : 'Zapisz ${kontrolery.length} fiszek',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
