import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'package:moneymanager_app/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  // S E T U P
  //initialize db
  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // G E T T E R S
  List<Expense> get allExpense => _allExpenses;

  //O P P E R A T I O N S
  // Create
  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense)); // add to db

    await readExpenses();
  }

  // Read
  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    notifyListeners();
  }

  // Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    await readExpenses();
  }

  // Delete
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));

    await readExpenses();
  }

  // H E L P E R
  //Total expenses for each month
  Future<Map<String,double>> calculateMonthlyTotals() async {
    await readExpenses();

    Map<String, double> monthlyTotals = {};

    for (var expense in _allExpenses) {
      String yearMonth = "${expense.date.year}-${expense.date.month}";

      if (!monthlyTotals.containsKey(yearMonth)){
        monthlyTotals[yearMonth] = 0;
      }

      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }
  
  //Current month total
  Future<double> calculateCurrentMonthTotal() async {
    await readExpenses();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth && expense.date.year == currentYear;
    }).toList();

    double total = currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  //Get start month
  int getStartMonth() {
    if(_allExpenses.isEmpty) {
      return DateTime.now().month;
    }
    _allExpenses.sort((a, b) => a.date.compareTo(b.date),);

    return _allExpenses.first.date.month;
  }

  //Get start year
  int getStartYear() {
    if(_allExpenses.isEmpty) {
      return DateTime.now().year;
    }
    _allExpenses.sort((a, b) => a.date.compareTo(b.date),);

    return _allExpenses.first.date.year;
  }

  //To get category totals for the month
  Future<Map<String, Map<ExpenseCategory, double>>> calculateMonthlyCategoryTotals() async {
    await readExpenses();
    
    Map<String, Map<ExpenseCategory, double>> categoryTotals = {};

    for (var expense in _allExpenses) {
      String yearMonth = "${expense.date.year}-${expense.date.month}";

      if (!categoryTotals.containsKey(yearMonth)) {
        categoryTotals[yearMonth] = {};
      }

      if (!categoryTotals[yearMonth]!.containsKey(expense.category)) {
        categoryTotals[yearMonth]![expense.category] = 0.0;
      }

      categoryTotals[yearMonth]![expense.category] = categoryTotals[yearMonth]![expense.category]! + expense.amount;
    }
    
    return categoryTotals;
  }

}