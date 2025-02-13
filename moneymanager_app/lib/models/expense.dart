import 'package:isar/isar.dart';

part 'expense.g.dart'; // dart run build_runner build

@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
  });
}