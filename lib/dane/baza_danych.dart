import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../modele/fiszka.dart';
import '../modele/zestaw.dart';

abstract interface class RepozytoriumFiszki {
  Future<List<Zestaw>> pobierzZestawy();

  Future<Zestaw> zapiszZestaw(Zestaw zestaw);

  Future<List<Fiszka>> dodajFiszki(Zestaw zestaw, List<Fiszka> fiszki);

  Future<void> usunZestaw(Zestaw zestaw);
}

class BazaDanych implements RepozytoriumFiszki {
  BazaDanych._();

  static final BazaDanych instancja = BazaDanych._();
  Database? _baza;

  Future<Database> get baza async {
    if (_baza != null) {
      return _baza!;
    }

    final sciezka = join(await getDatabasesPath(), 'kartonik.db');
    _baza = await openDatabase(
      sciezka,
      version: 1,
      onCreate: (baza, _) async {
        await baza.execute('''
          CREATE TABLE zestawy (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nazwa TEXT NOT NULL
          )
        ''');
        await baza.execute('''
          CREATE TABLE fiszki (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            zestaw_id INTEGER NOT NULL,
            przod TEXT NOT NULL,
            tyl TEXT NOT NULL,
            FOREIGN KEY (zestaw_id) REFERENCES zestawy (id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _baza!;
  }

  @override
  Future<List<Zestaw>> pobierzZestawy() async {
    final bazaDanych = await baza;
    final rekordyZestawow = await bazaDanych.query(
      'zestawy',
      orderBy: 'id DESC',
    );
    final zestawy = <Zestaw>[];

    for (final rekord in rekordyZestawow) {
      final idZestawu = rekord['id']! as int;
      final rekordyFiszek = await bazaDanych.query(
        'fiszki',
        where: 'zestaw_id = ?',
        whereArgs: [idZestawu],
        orderBy: 'id ASC',
      );
      zestawy.add(
        Zestaw(
          id: idZestawu,
          nazwa: rekord['nazwa']! as String,
          fiszki: rekordyFiszek
              .map(
                (fiszka) => Fiszka(
                  id: fiszka['id']! as int,
                  przod: fiszka['przod']! as String,
                  tyl: fiszka['tyl']! as String,
                ),
              )
              .toList(),
        ),
      );
    }
    return zestawy;
  }

  @override
  Future<Zestaw> zapiszZestaw(Zestaw zestaw) async {
    final bazaDanych = await baza;
    final idZestawu = await bazaDanych.insert('zestawy', {
      'nazwa': zestaw.nazwa,
    });

    for (final fiszka in zestaw.fiszki) {
      await bazaDanych.insert('fiszki', {
        'zestaw_id': idZestawu,
        'przod': fiszka.przod,
        'tyl': fiszka.tyl,
      });
    }

    return Zestaw(id: idZestawu, nazwa: zestaw.nazwa, fiszki: zestaw.fiszki);
  }

  @override
  Future<List<Fiszka>> dodajFiszki(Zestaw zestaw, List<Fiszka> fiszki) async {
    final idZestawu = zestaw.id;
    if (idZestawu == null) {
      throw StateError('Nie można dodać fiszki do niezapisanego zestawu.');
    }

    final bazaDanych = await baza;
    final zapisaneFiszki = <Fiszka>[];
    await bazaDanych.transaction((transakcja) async {
      for (final fiszka in fiszki) {
        final idFiszki = await transakcja.insert('fiszki', {
          'zestaw_id': idZestawu,
          'przod': fiszka.przod,
          'tyl': fiszka.tyl,
        });
        zapisaneFiszki.add(
          Fiszka(id: idFiszki, przod: fiszka.przod, tyl: fiszka.tyl),
        );
      }
    });
    return zapisaneFiszki;
  }

  @override
  Future<void> usunZestaw(Zestaw zestaw) async {
    final idZestawu = zestaw.id;
    if (idZestawu == null) {
      throw StateError('Nie można usunąć niezapisanego zestawu.');
    }

    final bazaDanych = await baza;
    await bazaDanych.transaction((transakcja) async {
      await transakcja.delete(
        'fiszki',
        where: 'zestaw_id = ?',
        whereArgs: [idZestawu],
      );
      await transakcja.delete(
        'zestawy',
        where: 'id = ?',
        whereArgs: [idZestawu],
      );
    });
  }
}
