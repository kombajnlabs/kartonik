import 'package:flutter/material.dart';

import '../modele/zestaw.dart';

class KartaZestawu extends StatelessWidget {
  const KartaZestawu({
    required this.zestaw,
    required this.onDodajFiszke,
    required this.onCwicz,
    required this.onUsun,
    super.key,
  });

  final Zestaw zestaw;
  final VoidCallback onDodajFiszke;
  final VoidCallback? onCwicz;
  final VoidCallback onUsun;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffe9e9f2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0d1b1b35),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.style_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    zestaw.nazwa,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onUsun,
                  tooltip: 'Usuń zestaw',
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xfff4f4fa),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.layers_outlined, size: 17),
                  const SizedBox(width: 7),
                  Text(
                    '${zestaw.fiszki.length} ${zestaw.fiszki.length == 1 ? 'fiszka' : 'fiszek'}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onDodajFiszke,
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj fiszkę'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onCwicz,
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Ćwicz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
