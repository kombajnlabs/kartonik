import 'package:flutter/material.dart';

class KontroleryFiszki {
  final TextEditingController przod = TextEditingController();
  final TextEditingController tyl = TextEditingController();

  void dispose() {
    przod.dispose();
    tyl.dispose();
  }
}

class FormularzFiszki extends StatelessWidget {
  const FormularzFiszki({
    required this.numer,
    required this.kontrolery,
    required this.moznaUsunac,
    required this.onUsun,
    super.key,
  });

  final int numer;
  final KontroleryFiszki kontrolery;
  final bool moznaUsunac;
  final VoidCallback onUsun;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Fiszka $numer',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (moznaUsunac)
                  IconButton(
                    onPressed: onUsun,
                    tooltip: 'Usuń fiszkę',
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            TextFormField(
              controller: kontrolery.przod,
              decoration: const InputDecoration(
                labelText: 'Przód / pytanie',
                hintText: 'Wpisz pytanie lub pojęcie',
                prefixIcon: Icon(Icons.help_outline),
                filled: true,
              ),
              validator: (wartosc) => wartosc == null || wartosc.trim().isEmpty
                  ? 'Wpisz przód fiszki'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: kontrolery.tyl,
              decoration: const InputDecoration(
                labelText: 'Tył / odpowiedź',
                hintText: 'Wpisz odpowiedź lub wyjaśnienie',
                prefixIcon: Icon(Icons.lightbulb_outline),
                filled: true,
              ),
              validator: (wartosc) => wartosc == null || wartosc.trim().isEmpty
                  ? 'Wpisz odpowiedź'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
