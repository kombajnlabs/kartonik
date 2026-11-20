import 'package:flutter/material.dart';

class PustyStan extends StatelessWidget {
  const PustyStan({required this.onUtworz, super.key});

  final VoidCallback onUtworz;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 58,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Nie masz jeszcze żadnego zestawu',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Zapisz słówka, pojęcia lub pytania i ucz się ich w swoim rytmie.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onUtworz,
                icon: const Icon(Icons.add),
                label: const Text('Utwórz zestaw'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
