import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kartonik/dane/baza_danych.dart';
import 'package:kartonik/ekrany/ekran_cwiczenia.dart';
import 'package:kartonik/ekrany/ekran_dodawania_fiszki.dart';
import 'package:kartonik/main.dart';
import 'package:kartonik/modele/fiszka.dart';
import 'package:kartonik/modele/zestaw.dart';

class PamiecoweRepozytorium implements RepozytoriumFiszki {
  final List<Zestaw> zestawy = <Zestaw>[];

  @override
  Future<List<Fiszka>> dodajFiszki(Zestaw zestaw, List<Fiszka> fiszki) async {
    zestaw.fiszki.addAll(fiszki);
    return fiszki;
  }

  @override
  Future<List<Zestaw>> pobierzZestawy() async => zestawy;

  @override
  Future<Zestaw> zapiszZestaw(Zestaw zestaw) async {
    zestawy.add(zestaw);
    return zestaw;
  }

  @override
  Future<void> usunZestaw(Zestaw zestaw) async {
    zestawy.remove(zestaw);
  }
}

void main() {
  testWidgets('Pusty ekran pozwala utworzyć zestaw', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AplikacjaFiszek(repozytorium: PamiecoweRepozytorium()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nie masz jeszcze żadnego zestawu'), findsOneWidget);
    await tester.tap(find.text('Utwórz zestaw'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy zestaw'), findsOneWidget);
    expect(find.text('Nazwa zestawu'), findsOneWidget);
    expect(find.text('Utwórz zestaw'), findsOneWidget);
  });

  testWidgets('Formularz odrzuca pustą nazwę zestawu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AplikacjaFiszek(repozytorium: PamiecoweRepozytorium()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utwórz zestaw'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utwórz zestaw'));
    await tester.pump();

    expect(find.text('Wpisz nazwę zestawu'), findsOneWidget);
  });

  testWidgets('Dodawanie pól nie duplikuje ich stanu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AplikacjaFiszek(repozytorium: PamiecoweRepozytorium()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utwórz zestaw'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dodaj'));
    await tester.tap(find.text('Dodaj'));
    await tester.pumpAndSettle();

    expect(find.text('Fiszka 1'), findsOneWidget);
    expect(find.text('Fiszka 2'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Fiszka 3'), findsOneWidget);
  });

  testWidgets('Dobra odpowiedź zwiększa wynik i przechodzi dalej', (
    WidgetTester tester,
  ) async {
    final zestaw = Zestaw(
      nazwa: 'Test',
      fiszki: [
        Fiszka(przod: 'Pierwsze', tyl: '1'),
        Fiszka(przod: 'Drugie', tyl: '2'),
      ],
    );
    await tester.pumpWidget(MaterialApp(home: EkranCwiczenia(zestaw: zestaw)));

    expect(find.text('0 pkt'), findsOneWidget);
    await tester.tap(find.text('Dobrze'));
    await tester.pumpAndSettle();

    expect(find.text('1 pkt'), findsOneWidget);
    expect(find.text('Drugie'), findsOneWidget);
  });

  testWidgets('Zapisuje wiele fiszek jednym działaniem', (
    WidgetTester tester,
  ) async {
    final zapisaneFiszki = <Fiszka>[];
    final zestaw = Zestaw(id: 1, nazwa: 'Słówka');
    await tester.pumpWidget(
      MaterialApp(
        home: EkranDodawaniaFiszki(
          zestaw: zestaw,
          onDodajFiszki: (fiszki) async => zapisaneFiszki.addAll(fiszki),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Pierwsze pytanie',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Pierwsza odpowiedź',
    );
    await tester.tap(find.text('Dodaj kolejną fiszkę'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Drugie pytanie');
    await tester.enterText(find.byType(TextFormField).at(1), 'Druga odpowiedź');
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zapisz 2 fiszek'));
    await tester.pumpAndSettle();

    expect(zapisaneFiszki, hasLength(2));
  });
}
