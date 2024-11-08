import 'package:flutter/material.dart';
import 'package:md_final/nutrition_page/nutrition_page.dart';
import 'package:md_final/profile_page/profile_page.dart';

// function to trigger build when the app is run
void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomePage(),
      '/nutrition': (context) => const NutritionPage(),
      '/profile': (context) => const ProfilePage(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('to nutrition page'),
              onPressed: () {
                Navigator.pushNamed(context, '/nutrition');
              },
            ),
            ElevatedButton(
              child: const Text('to profile'),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Workout App'),
      backgroundColor: Colors.green,
    );
  }
}