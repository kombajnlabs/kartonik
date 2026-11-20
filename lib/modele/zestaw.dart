import 'fiszka.dart';

class Zestaw {
  Zestaw({this.id, required this.nazwa, List<Fiszka>? fiszki})
    : fiszki = fiszki ?? <Fiszka>[];

  final int? id;
  final String nazwa;
  final List<Fiszka> fiszki;
}
