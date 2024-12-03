import 'package:flutter/material.dart';
import 'nutrition_page_dashboard.dart';
import 'nutrition_page_log.dart';
import 'nutrition_page_goals.dart';

/// The main NutritionPage widget that contains three tabs: Dashboard, Log, and Goals.
class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition Page'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Dashboard"),
              Tab(text: "Log"),
              Tab(text: "Goals"),
            ],
          ),
        ),
        body: const TabBarView(
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
