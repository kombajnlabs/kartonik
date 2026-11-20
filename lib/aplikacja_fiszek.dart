import 'package:flutter/material.dart';

import 'dane/baza_danych.dart';
import 'ekrany/ekran_glowny.dart';
import 'modele/fiszka.dart';
import 'modele/zestaw.dart';
import 'styl/motyw_aplikacji.dart';

class AplikacjaFiszek extends StatefulWidget {
  const AplikacjaFiszek({this.repozytorium, super.key});

  final RepozytoriumFiszki? repozytorium;

  @override
  State<AplikacjaFiszek> createState() => _StanAplikacjiFiszek();
}

class _StanAplikacjiFiszek extends State<AplikacjaFiszek> {
  late final RepozytoriumFiszki repozytorium;
  late Future<List<Zestaw>> ladowanieZestawow;
  List<Zestaw> zestawy = <Zestaw>[];

  @override
  void initState() {
    super.initState();
    repozytorium = widget.repozytorium ?? BazaDanych.instancja;
    ladowanieZestawow = wczytajZestawy();
  }

  Future<List<Zestaw>> wczytajZestawy() async {
    zestawy = await repozytorium.pobierzZestawy();
    return zestawy;
  }

  Future<void> dodajZestaw(Zestaw zestaw) async {
    final zapisanyZestaw = await repozytorium.zapiszZestaw(zestaw);
    if (mounted) {
      setState(() => zestawy = [...zestawy, zapisanyZestaw]);
    }
  }

  Future<void> dodajFiszki(Zestaw zestaw, List<Fiszka> fiszki) async {
    final zapisaneFiszki = await repozytorium.dodajFiszki(zestaw, fiszki);
    if (mounted) {
      setState(() => zestaw.fiszki.addAll(zapisaneFiszki));
    }
  }

  Future<void> usunZestaw(Zestaw zestaw) async {
    await repozytorium.usunZestaw(zestaw);
    if (mounted) {
      setState(() => zestawy.remove(zestaw));
    }
  }

  Widget ekranStartowy() {
    return FutureBuilder<List<Zestaw>>(
      future: ladowanieZestawow,
      builder: (context, wynik) {
        if (wynik.hasError) {
          return _EkranBledu(
            blad: wynik.error!,
            onPonow: () => setState(() {
              ladowanieZestawow = wczytajZestawy();
            }),
          );
        }
        if (!wynik.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Przygotowujemy Twoje fiszki...'),
                ],
              ),
            ),
          );
        }
        return EkranGlowny(
          zestawy: zestawy,
          onDodajZestaw: dodajZestaw,
          onDodajFiszki: dodajFiszki,
          onUsunZestaw: usunZestaw,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kartonik',
      debugShowCheckedModeBanner: false,
      theme: motywAplikacji(),
      home: ekranStartowy(),
    );
  }
}

class _EkranBledu extends StatelessWidget {
  const _EkranBledu({required this.blad, required this.onPonow});

  final Object blad;
  final VoidCallback onPonow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 42,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Coś poszło nie tak',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nie udało się otworzyć zapisanych fiszek.\n$blad',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onPonow,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
