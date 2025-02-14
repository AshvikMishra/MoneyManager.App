import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneymanager_app/bar%20graph/individual_bar.dart';
import 'package:moneymanager_app/models/expense.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummary[index],
      ),
    );
  }

  double calculateMax() {
    double max = 500;

    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;

    if (max < 5000) {
      return 5000;
    }

    return max;
  }

  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length + spaceBetweenBars * (barData.length),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                    reservedSize: 40,
                  ),
                ),
              ),
              barGroups: barData.map(
                (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      toY: data.y,
                      width: barWidth,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade800,
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: calculateMax(),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
    const textstyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text;
    switch (value.toInt()%12) {
      case 0: text = "J"; break;
      case 1: text = "F"; break;
      case 2: text = "M"; break;
      case 3: text = "A"; break;
      case 4: text = "M"; break;
      case 5: text = "J"; break;
      case 6: text = "J"; break;
      case 7: text = "A"; break;
      case 8: text = "S"; break;
      case 9: text = "O"; break;
      case 10: text = "N"; break;
      case 11: text = "D"; break;
      default: text = ""; break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: textstyle,));
  }

//Bar Chart for Categories:

class MyCategoryBarGraph extends StatefulWidget {
  final Map<String, Map<ExpenseCategory, double>> categoryTotals; // data for each category per month
  final int startMonth;

  const MyCategoryBarGraph({
    super.key,
    required this.categoryTotals,
    required this.startMonth,
  });

  @override
  State<MyCategoryBarGraph> createState() => _MyCategoryBarGraphState();
}

class _MyCategoryBarGraphState extends State<MyCategoryBarGraph> {
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  void initializeBarData() {
    if (widget.categoryTotals.isEmpty) {
      barData = [];
      return;
    }

    // Get the first month's data (if available)
    var firstMonthData = widget.categoryTotals.entries.first.value;

    if (firstMonthData.isEmpty) {
      barData = [];
      return;
    }

    // Convert category data into IndividualBar objects
    barData = firstMonthData.entries.map(
      (entry) => IndividualBar(
        x: entry.key.index, // Using the category index as the x-value
        y: entry.value, // Expense amount
      ),
    ).toList();
  }

  double calculateMax() {
    double max = 500;

    barData.forEach((bar) {
      if (bar.y > max) max = bar.y;
    });

    return max * 1.05;
  }

  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 50;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length + spaceBetweenBars * (barData.length),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles2,
                    reservedSize: 40,
                  ),
                ),
              ),
              barGroups: barData.map(
                (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      toY: data.y,
                      width: barWidth,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade800,
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: calculateMax(),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitles2(double value, TitleMeta meta) {
  const textstyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  // Create a list of category names from ExpenseCategory
  List<String> categories = ExpenseCategory.values.map((e) => e.name).toList();

  String text = categories[value.toInt() % categories.length];
  return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: textstyle));
}