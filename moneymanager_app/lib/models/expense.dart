import 'package:isar/isar.dart';

part 'expense.g.dart'; // dart run build_runner build

enum ExpenseCategory {
  Food,
  Transport,
  Bills,
  Entertainment,
  Shopping,
  Other,
}

@collection
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;

  @enumerated
  final ExpenseCategory category;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  });
}
