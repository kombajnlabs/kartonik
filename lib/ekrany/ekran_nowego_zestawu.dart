import 'package:flutter/material.dart';

import '../modele/fiszka.dart';
import '../modele/zestaw.dart';
import '../widgety/formularz_fiszki.dart';

class EkranNowegoZestawu extends StatefulWidget {
  const EkranNowegoZestawu({super.key});

  @override
  State<EkranNowegoZestawu> createState() => _StanNowegoZestawu();
}

class _StanNowegoZestawu extends State<EkranNowegoZestawu> {
  final GlobalKey<FormState> kluczFormularza = GlobalKey<FormState>();
  final TextEditingController kontrolerNazwy = TextEditingController();
  final List<KontroleryFiszki> kontrolery = <KontroleryFiszki>[
    KontroleryFiszki(),
  ];

  @override
  void dispose() {
    kontrolerNazwy.dispose();
    for (final formularz in kontrolery) {
      formularz.dispose();
    }
    super.dispose();
  }

  void dodajPoleFiszki() {
    setState(() => kontrolery.insert(0, KontroleryFiszki()));
  }

  void zapisz() {
    if (!(kluczFormularza.currentState?.validate() ?? false)) {
      return;
    }
    final fiszki = kontrolery
        .where((formularz) => formularz.przod.text.trim().isNotEmpty)
        .map(
          (formularz) => Fiszka(
            przod: formularz.przod.text.trim(),
            tyl: formularz.tyl.text.trim(),
          ),
        )
        .toList();
    Navigator.of(
      context,
    ).pop(Zestaw(nazwa: kontrolerNazwy.text.trim(), fiszki: fiszki));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowy zestaw')),
      body: Form(
        key: kluczFormularza,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Stwórz przestrzeń do nauki',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Nadaj zestawowi nazwę i dodaj pierwsze fiszki.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: const Color(0xff77778b)),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: kontrolerNazwy,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nazwa zestawu',
                hintText: 'np. Angielski - podstawy',
              ),
              validator: (wartosc) => wartosc == null || wartosc.trim().isEmpty
                  ? 'Wpisz nazwę zestawu'
                  : null,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: const Icon(Icons.style_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fiszki w zestawie',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${kontrolery.length} ${kontrolery.length == 1 ? 'pole' : 'pól'} do uzupełnienia',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: dodajPoleFiszki,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Dodaj'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...kontrolery.asMap().entries.map(
              (wpis) => FormularzFiszki(
                key: ObjectKey(wpis.value),
                numer: wpis.key + 1,
                kontrolery: wpis.value,
                moznaUsunac: kontrolery.length > 1,
                onUsun: () => setState(() {
                  wpis.value.dispose();
                  kontrolery.removeAt(wpis.key);
                }),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: zapisz,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Utwórz zestaw'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
