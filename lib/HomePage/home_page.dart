import 'package:flutter/material.dart';
import 'package:md_final/global_widgets/build_bottom_app_bar.dart';

import '../global_widgets/user_prefs_database_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    DatabaseModel userPrefs = DatabaseModel();
    userPrefs.insertOption("test", "test_result");
    return Scaffold(
      appBar: AppBar(title: Text("Home Page"), automaticallyImplyLeading: false),
    );
  }

}