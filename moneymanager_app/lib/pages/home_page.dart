import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:moneymanager_app/bar%20graph/bar_graph.dart';
import 'package:moneymanager_app/components/my_list_tile.dart';
import 'package:moneymanager_app/database/expense_database.dart';
import 'package:moneymanager_app/helper/helper_functions.dart';
import 'package:moneymanager_app/models/expense.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage>  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  bool _showCategoryChart = false; // Toggle switch state

  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<Map<String, Map<ExpenseCategory, double>>>? _categoryTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshData();
  }

  void refreshData() {
    _monthlyTotalsFuture =
        Provider.of<ExpenseDatabase>(context, listen: false).calculateMonthlyTotals();
    _categoryTotalsFuture =
        Provider.of<ExpenseDatabase>(context, listen: false).calculateMonthlyCategoryTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false).calculateCurrentMonthTotal();
  }
 
  void openNewExpenseBox() {
  ExpenseCategory selectedCategory = ExpenseCategory.Food; // Default category

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder( // Use StatefulBuilder for state updates
      builder: (context, setState) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
              keyboardType: TextInputType.number, // Ensures numeric input
            ),
            const SizedBox(height: 16),

            // Dropdown for selecting category
            DropdownButton<ExpenseCategory>(
              value: selectedCategory,
              isExpanded: true,
              onChanged: (ExpenseCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                }
              },
              items: ExpenseCategory.values.map((ExpenseCategory category) {
                return DropdownMenuItem<ExpenseCategory>(
                  value: category,
                  child: Text(category.name), // Display enum value as text
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _createNewExpenseButton(selectedCategory), // Pass selected category
        ],
      ),
    ),
  );
}

  void openEditBox(Expense expense) {
  nameController.text = expense.name;
  amountController.text = expense.amount.toString();
  ExpenseCategory selectedCategory = expense.category; // Preserve previous category

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Dropdown for selecting category
            DropdownButton<ExpenseCategory>(
              value: selectedCategory,
              isExpanded: true,
              onChanged: (ExpenseCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                }
              },
              items: ExpenseCategory.values.map((ExpenseCategory category) {
                return DropdownMenuItem<ExpenseCategory>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _editExpenseButton(expense, selectedCategory),
        ],
      ),
    ),
  );
}
  
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete expense?"),

        actions: [
          _cancelButton(),
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  bool _isDarkMode = false;
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

        List<Expense> currentMonthExpenses = value.allExpense
            .where((expense) => expense.date.year == currentYear && expense.date.month == currentMonth)
            .toList();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),
          home: Scaffold(
            backgroundColor: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            floatingActionButton: Container(
              constraints: const BoxConstraints(maxWidth: 200, maxHeight: 50),
              child: FloatingActionButton.extended(
                onPressed: openNewExpenseBox,
                label: Text(
                  "Add Expense",
                  style: TextStyle(color: _isDarkMode ? Colors.grey.shade800 : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                icon: Icon(Icons.attach_money, color: _isDarkMode ? Colors.grey.shade800 : Colors.white, size: 18),
                backgroundColor: _isDarkMode ? Colors.white: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: FutureBuilder<double>(
                future: _calculateCurrentMonthTotal,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getCurrentMonthName()),
                        Text("\₹${snapshot.data!.toStringAsFixed(2)}"),
                        IconButton(
                          icon: Icon(
                            _isDarkMode ? Icons.nights_stay : Icons.sunny,
                            color: _isDarkMode ? Colors.white : Colors.grey.shade800,
                            size: 25,
                          ),
                          onPressed: () {
                            _toggleDarkMode();
                          },
                        ),
                      ],
                    );
                  } else {
                    return const Text("Loading...");
                  }
                },
              ),
            ),
            
            body: SafeArea(
              child: Column(
                children: [
                  // Bar Chart Section
                  SizedBox(
                    height: 250,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50), // Leave 50px on each side
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4), // Add border radius
                        ),
                        child: _showCategoryChart
                            ? FutureBuilder(
                                future: _categoryTotalsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    Map<String, Map<ExpenseCategory, double>> categoryTotals =
                                        snapshot.data ?? {};

                                    return MyCategoryBarGraph(
                                      categoryTotals: categoryTotals,
                                      startMonth: startMonth,
                                    );
                                  } else {
                                    return const Center(child: Text("Loading..."));
                                  }
                                },
                              )
                            : FutureBuilder(
                                future: _monthlyTotalsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    Map<String, double> monthlyTotals = snapshot.data ?? {};

                                    List<double> monthlySummary = List.generate(monthCount, (index) {
                                      int year = startYear + (startMonth + index - 1) ~/ 12;
                                      int month = (startMonth + index - 1) % 12 + 1;
                                      String yearMonthKey = "$year-$month";
                                      return monthlyTotals[yearMonthKey] ?? 0.0;
                                    });

                                    return MyBarGraph(
                                      monthlySummary: monthlySummary,
                                      startMonth: startMonth,
                                    );
                                  } else {
                                    return const Center(child: Text("Loading..."));
                                  }
                                },
                              ),
                      ),
                    ),
                  ),

                  // Toggle Switch for Chart View
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return ToggleButtons(
                        borderRadius: BorderRadius.circular(4),
                        selectedColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                        fillColor: _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                        color: _isDarkMode ? Colors.white : Colors.grey.shade800,
                        isSelected: [!_showCategoryChart, _showCategoryChart],
                        onPressed: (index) {
                          setState(() {
                            _showCategoryChart = index == 1;
                          });
                        },
                        constraints: BoxConstraints(
                          minWidth: (constraints.maxWidth - 50) / 2,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: constraints.maxWidth < 300
                                ? const Column(
                                    children: [
                                      Text("Monthly", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Text("Expenses", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : const Text("Monthly Expenses", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: constraints.maxWidth < 300
                                ? const Column(
                                    children: [
                                      Text("Category", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Text("Expenses", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : const Text("Category Expenses", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  ),
          
                  const SizedBox(height: 5,),
          
                  // Expense List
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentMonthExpenses.length,
                      itemBuilder: (context, index) {
                        int reversedIndex = currentMonthExpenses.length - 1 - index;
                        Expense individualExpense = currentMonthExpenses[reversedIndex];
          
                        return MyListTile(
                          title: individualExpense.name,
                          trailing: formatAmount(individualExpense.amount),
                          onEditPressed: (context) => openEditBox(individualExpense),
                          onDeletePressed: (context) => openDeleteBox(individualExpense),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);

        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  Widget _createNewExpenseButton(ExpenseCategory selectedCategory) {
  return MaterialButton(
    onPressed: () async {
      if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
        Navigator.pop(context);

        Expense newExpense = Expense(
          name: nameController.text,
          amount: convertStringToDouble(amountController.text),
          date: DateTime.now(),
          category: selectedCategory, // Save selected category
        );

        await context.read<ExpenseDatabase>().createNewExpense(newExpense);

        nameController.clear();
        amountController.clear();

        refreshData();
      }
    },
    child: const Text("Save"),
  );
}

  Widget _editExpenseButton(Expense expense, ExpenseCategory selectedCategory) {
  return MaterialButton(
    onPressed: () async {
      if (nameController.text.isNotEmpty || amountController.text.isNotEmpty) {
        Navigator.pop(context);

        Expense updatedExpense = Expense(
          name: nameController.text.isNotEmpty
              ? nameController.text
              : expense.name,
          amount: amountController.text.isNotEmpty
              ? convertStringToDouble(amountController.text)
              : expense.amount,
          date: expense.date, // Keep original date
          category: selectedCategory, // Updated category
        );

        await context.read<ExpenseDatabase>().updateExpense(expense.id, updatedExpense);

        refreshData();
      }
    },
    child: const Text("Save"),
  );
}

  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        
        await context.read<ExpenseDatabase>().deleteExpense(id);

        refreshData();
      },
      child: const Text("Delete"),
    );
  }

}