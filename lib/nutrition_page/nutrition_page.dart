import 'package:flutter/material.dart';
import 'nutrition_page_dashboard.dart';
import 'nutrition_page_log.dart';
import 'nutrition_page_goals.dart';

class NutritionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nutrition Page'),
          bottom: TabBar(
            tabs: [
              Tab(text: "Dashboard"),
              Tab(text: "Log"),
              Tab(text: "Goals"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NutritionPageDashboard(),
            NutritionPageLog(),
            NutritionPageGoals(),
          ],
        ),
      ),
    );
  }
}
